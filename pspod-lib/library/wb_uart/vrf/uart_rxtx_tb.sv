
// UART receiver and transmitter test with UART model

module uart_rxtx_tb #(
    parameter SEED = 0
);
    timeunit 1ns;
    timeprecision 1ns;

    bit verbose = 0;
    int test_size = 50;

    parameter T_clk = 20ns;
    logic clk;
    logic rst;

    initial begin
        clk = '0;
        forever #(T_clk / 2) clk <= ~clk;
    end

    initial begin
        rst <= 1;
        #(2 * T_clk);
        rst <= 0;
    end

    // ------------------------------------------------

    logic [15:0] baud_div;
    logic rx, tx;

    bit [7:0] rx_buf [$];
    byte tx_buf [$];

    logic [7:0] rx_data;
    logic       rx_ready;

    uart_receiver #(1, 1) receiver (
        .clk_i      ( clk      ),
        .rst_i      ( rst      ),
        .baud_div_i ( baud_div ),
        .rx_i       ( rx       ),
        .data_o     ( rx_data  ),
        .ready_o    ( rx_ready )
    );

    always @(posedge clk) begin
        if (rx_ready) begin
            rx_buf.push_back(rx_data);
            if (verbose)
                $display("%t | %m : receive byte %2x", $time, rx_data);
        end
    end

    logic [7:0] tx_data;
    logic       tx_req;
    logic       tx_done;

    uart_transmitter transmitter (
        .clk_i      ( clk      ),
        .rst_i      ( rst      ),
        .baud_div_i ( baud_div ),
        .data_i     ( tx_data  ),
        .req_i      ( tx_req   ),
        .done_o     ( tx_done  ),
        .ready_o    (          ),
        .tx_o       ( tx       )
    );

    // ------------------------------------------------

    logic stub_tx, stub_rx;

    uart_model stub (
        .tx_o ( stub_tx ),
        .rx_i ( stub_rx )
    );

    // ------------------------------------------------

    initial begin
        $display("\n%m : Start!\n");
        $urandom(SEED);
        tx_req = 0;
        #(100 * T_clk);

        // Baudrate 115200
        baud_div = 26;
        stub.setup(.baudrate(115200));

        verbose = 1;
        stub.verbose = 1;
        compare_fifos._verbose = 1;

        // ------------------------------------------------
        // UART model  -> Receiver
        // ------------------------------------------------

        #(1000 * T_clk);

        $display("%m | Model -> Receiver test...\n");
        assign rx = stub_tx;
        #(10 * T_clk);

        clear_buffers();
        repeat (test_size) begin
            automatic byte tmp = $urandom;
            tx_buf.push_back(tmp);
            stub.tx_fifo.push_back(tmp);
        end

        wait (rx_buf.size() == test_size);

        check_result(tx_buf, rx_buf);

        assign rx = 1;

        // ------------------------------------------------
        // Transmitter -> UART model
        // ------------------------------------------------

        #(1000 * T_clk);

        $display("\n%m | Transmitter -> Model test...\n");
        assign stub_rx = tx;
        #(10 * T_clk);

        clear_buffers();
        repeat (test_size) begin
            transmit_data($urandom);
        end

        wait (stub.rx_fifo.size() == test_size);

        check_result(tx_buf, stub.rx_fifo);

        assign stub_rx = 1;

        // ------------------------------------------------
        // UART model loopback
        // ------------------------------------------------

        #(1000 * T_clk);

        $display("\n%m | Model loopback test...\n");
        assign stub_rx = stub_tx;
        #(10 * T_clk);

        clear_buffers();
        repeat (test_size) begin
            automatic byte tmp = $urandom;
            tx_buf.push_back(tmp);
            stub.tx_fifo.push_back(tmp);
        end

        wait (stub.rx_fifo.size() == test_size);

        check_result(tx_buf, stub.rx_fifo);

        assign stub_rx = 1;

        // ------------------------------------------------
        // Transmitter -> Receiver
        // ------------------------------------------------

        #(1000 * T_clk);

        $display("\n%m | Transmitter -> Receiver test...\n");
        assign rx = tx;
        #(10 * T_clk);

        clear_buffers();
        repeat (test_size) begin
            transmit_data($urandom);
        end

        wait (rx_buf.size() == test_size);

        check_result(tx_buf, rx_buf);

        assign rx = 1;

        // ------------------------------------------------

        $display("\n%m : Test passed!\n");
        #(100 * T_clk);
        $stop;
    end

    task automatic transmit_data(byte data);
        tx_buf.push_back(data);

        if (verbose)
            $display("%t | %m : transmit byte %2x", $time, data);

        @(posedge clk);
        tx_data = data;
        tx_req = 1;
        @(posedge clk);
        tx_req = 0;

        @(posedge tx_done);
    endtask

    function automatic void check_result(ref byte tx_buf [$], ref bit [7:0] rx_buf [$]);
        if (!compare_fifos(tx_buf, rx_buf)) begin
            $display("%t : %m | Error! Data mismatch!", $time);
            $stop;
        end
    endfunction

    function automatic bit compare_fifos(ref byte fifo1 [$], ref bit [7:0] fifo2 [$]);
        static bit _verbose = 0;

        if (fifo1.size() != fifo2.size())
            return 0;

        foreach (fifo1[i]) begin
            if (_verbose)
                $display("%3d : F1 - %2x | F2 - %2x", i, fifo1[i], fifo2[i]);

            if (fifo1[i] != fifo2[i])
                return 0;
        end

        return 1;
    endfunction

    function void clear_buffers();
        tx_buf = {};
        rx_buf = {};
        stub.rx_fifo = {};
    endfunction


endmodule
