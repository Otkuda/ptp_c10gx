
`default_nettype none

module wb_uart_tb ();
    timeunit 1ns;
    timeprecision 1ps;

    time T_clk_ns = 40ns;

    logic clk = 1'b0;
    logic reset = 1'b1;

    always  #(T_clk_ns / 2) clk = ~clk;
    initial #(100 * T_clk_ns) reset = 1'b0;

    int F_clk_hz;
    initial begin
        F_clk_hz = 1.0e+9 / (1.0 * T_clk_ns);
    end

    //-----------------------------------------------
    // DUT
    //-----------------------------------------------

    wb_if wb_cpu (clk, reset);

    wire uart_tx;
    wire uart_rx;
    logic [15:0] baud_div;

    wb_uart #(
        .TX_DPTH_W (4) ,
        .RX_DPTH_W (4)
    ) dut (
        .wb_clk_i   (clk),
        .wb_rst_i   (reset),
        .wbs        (wb_cpu),
        .baud_div_i (baud_div),
        .tx_o       (uart_tx),
        .rx_i       (uart_rx)
    );

    //-----------------------------------------------
    // Master BFM
    //-----------------------------------------------

     enum {
        DATA_ADDR = 0,
        RX_STATUS = 4,
        TX_STATUS = 8
    } uart_reg_addr_t;

    wb_bfm_master_wrp mst (
        .clk_i (clk),
        .rst_i (reset),
        .wbm   (wb_cpu)
    );

    task automatic reg_write(int addr, int d);
        bit err;
        mst.inst.wait_states = $urandom_range(0,4);
        mst.inst.insert_wait_states;
        mst.inst.write(addr, d, '1, err);
    endtask

    task automatic reg_read(int addr, output int d);
        bit err;
        mst.inst.addr = addr;
        mst.inst.op = 0;
        mst.inst.init();
        mst.inst.next();
        d = mst.inst.data;
        mst.inst.wait_states = $urandom_range(0,4);
        mst.inst.insert_wait_states;
    endtask

    bit [7:0] rx_rdbuf [$];

    task automatic wb_read_rx_data(int rd_num, bit clr_buf=1);
        int rd;
        int rd_cnt = 0;
        if (clr_buf)
            rx_rdbuf = {};

        do begin
            reg_read(RX_STATUS, rd);
            if (rd & 1) begin
                reg_read(DATA_ADDR, rd);
                rx_rdbuf.push_back(rd[7:0]);
                rd_cnt++;
                tick(2);
            end
        end while (rd_cnt != rd_num);
    endtask

    bit [7:0] tx_wrbuf [$];

    task automatic wb_write_tx_data(int wr_num, bit clr_buf=1);
        int rd;
        int wr_cnt = 0;
        if (clr_buf)
            tx_wrbuf = {};

        do begin
            reg_read(8, rd);
            if (rd & 1) begin
                tx_wrbuf.push_back($urandom);
                reg_write(0, tx_wrbuf[$]);
                wr_cnt++;
                tick(2);
            end
        end while (wr_cnt != wr_num);
    endtask

    //-----------------------------------------------
    // UART model
    //-----------------------------------------------

    uart_model model (
        .tx_o (uart_rx),
        .rx_i (uart_tx)
    );

    function void configure_baudrate(int baudrate);
        model.setup(.baudrate(baudrate));
        baud_div = (1.0 * F_clk_hz) / (1.0 * dut.uart_tx.SMPL_N * baudrate) - 1;
    endfunction

    //-----------------------------------------------
    // Tests
    //-----------------------------------------------

    typedef bit [7:0] queue_t[$];

    function automatic void compare_data(ref queue_t buf1, ref queue_t buf2);
        assert (buf1.size() == buf2.size()) else $stop;
        foreach (buf1[i]) begin
            assert (buf1[i] == buf2[i]) else $stop;
        end
    endfunction

    int data_num_max = 20;
    int iter_num = 1;

    function automatic void get_args();
        if (!$value$plusargs("data_num_max=%d", data_num_max))
            data_num_max = 20;
        if (!$value$plusargs("iter_num=%d", iter_num))
            iter_num = 1;
    endfunction

    function automatic int get_baudrate();
        int baudrate;
        randcase
            2: baudrate = 19200  ;
            2: baudrate = 28800  ;
            2: baudrate = 38400  ;
            2: baudrate = 57600  ;
            2: baudrate = 76800  ;
            2: baudrate = 115200 ;
            1: baudrate = $urandom_range(19200, 115200);
        endcase
        $display("Baudrate = %0d", baudrate);
        return baudrate;
    endfunction

    function automatic int get_data_num(int baudrate);
        int data_n;
        case (1)
        (baudrate <= 28800 ): data_n = 2 * $urandom_range(5, 10);
        (baudrate <= 38400 ): data_n = 2 * $urandom_range(10, 20);
        (baudrate <= 57600 ): data_n = 2 * $urandom_range(20, 30);
        (baudrate <= 76800 ): data_n = 2 * $urandom_range(30, 40);
        (baudrate <= 115200): data_n = 2 * $urandom_range(40, 50);
        endcase
        $display("Data amount = %0d", data_n);
        return data_n;
    endfunction

    task automatic tx_test();
        int bdrt = get_baudrate();
        int data_n = get_data_num(bdrt);
        $display("TX test");
        configure_baudrate(bdrt);
        tick(10);
        fork
            model.wait_recv_data(data_n);
            begin
                tick(1);
                wb_write_tx_data(data_n);
            end
        join
        compare_data(tx_wrbuf, model.rx_fifo);
        $display("TX test done!");
    endtask

    bit [7:0] tx_model_wrdat [$];

    task tx_model_send_data(int data_num);
        tx_model_wrdat = {};
        void'(std::randomize(tx_model_wrdat) with {
            tx_model_wrdat.size() == data_num;
        });
        model.tx_fifo = tx_model_wrdat;
        #(1ns * model.get_timeout_ns(data_num+1));
    endtask

    task automatic rx_test();
        int bdrt = get_baudrate();
        int data_n = get_data_num(bdrt);
        $display("RX test");
        configure_baudrate(bdrt);
        tick(10);
        fork
            wb_read_rx_data(data_n);
            begin
                tick(10);
                tx_model_send_data(data_n);
            end
        join
        compare_data(tx_model_wrdat, rx_rdbuf);
        $display("RX test done!");
    endtask

    //-----------------------------------------------
    // Run tests
    //-----------------------------------------------

    initial begin : run
        get_args();
        mst.inst.reset();
        wait (reset === 1'b1);
        wait (reset === 1'b0);
        tick(100);

        for (int iter = 0; iter < iter_num; ++iter) begin
            $display("Start test %0d", iter);
            tx_test();
            rx_test();
            $display("");
        end

        $display("FINISH!");

        $stop;
    end

    task wait_for_nba_region;
        int nba;
        int next_nba;
        next_nba++;
        nba <= next_nba;
        @(nba);
    endtask

    task tick(int n);
        #(T_clk_ns * 1ns * n);
    endtask

endmodule

`default_nettype wire
