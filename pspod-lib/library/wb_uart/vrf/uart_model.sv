
// Simple UART model
// Frame format - 1 START, 8 DATA (LSB first), 1 STOP

module uart_model (
    output logic tx_o,
    input  logic rx_i
);
    timeunit 1ns;
    timeprecision 1ps;

    bit verbose = 0;

    // ------------------------------------------
    // Configuration
    // ------------------------------------------

    int  T_clk_ns   ;
    int  sample_num ;
    int  buad_div   ;

    function void setup(int _T_clk_ns=20, _sample_num=1, baudrate=115200);
        int F_clk_hz;

        T_clk_ns = _T_clk_ns;
        F_clk_hz = 1.0e+9 / (1.0 * T_clk_ns);
        sample_num = _sample_num;
        buad_div = (1.0 * F_clk_hz) / (1.0 * baudrate * sample_num);
    endfunction

    initial setup();

    // Time for transfer N bytes
    function int get_timeout_ns(int N);
        return buad_div * sample_num * T_clk_ns * 10 * N;
    endfunction

    // ------------------------------------------
    // Transmitter
    // ------------------------------------------

    bit [7:0] tx_data;
    bit [7:0] tx_fifo [$];

    initial begin : tx_thread
        $timeformat(-9, 0, "ns", 12);
        tx_o = 1;

        forever begin
            if (tx_fifo.size() > 0) begin
                tx_data = tx_fifo.pop_front();

                if (verbose) begin
                    $display("%t | %m : transmit byte %2x", $time, tx_data);
                end

                __transmit_byte(tx_data);
            end else begin
                #(T_clk_ns);
            end
        end
    end

    enum {TX_IDLE, TX_START, TX_DATA, TX_STOP} tx_state = TX_IDLE;

    task __transmit_byte(input byte data);
        tx_state = TX_START;
        tx_o = 0;
        #(buad_div * sample_num * T_clk_ns);

        tx_state = TX_DATA;
        repeat (8) begin
            tx_o = data[0];
            #(buad_div * sample_num * T_clk_ns);
            data = data >> 1;
        end

        tx_state = TX_STOP;
        tx_o = 1;
        #(buad_div * sample_num * T_clk_ns);

        tx_state = TX_IDLE;
    endtask

    // ------------------------------------------
    // Receiver
    // ------------------------------------------

    bit [7:0] rx_data;
    bit [7:0] rx_fifo [$];

    enum {RX_IDLE, RX_START, RX_DATA, RX_STOP} rx_state = RX_IDLE;

    always begin : rx_thread
        __receive_byte(rx_data);

        if (verbose) begin
            $display("%t | %m : receive byte %2x", $time, rx_data);
        end

        rx_fifo.push_back(rx_data);
    end

    task __receive_byte(output byte data);
        data = '0;

        @(negedge rx_i);
        rx_state = RX_START;
        #(((buad_div * sample_num) / 2) * T_clk_ns);

        rx_state = RX_DATA;
        repeat (8) begin
            #(buad_div * sample_num * T_clk_ns);
            data = {rx_i, data[7:1]};
        end

        rx_state = RX_STOP;
        #(buad_div * (sample_num + sample_num / 2) * T_clk_ns);

        rx_state = RX_IDLE;
    endtask

    task wait_recv_data(int data_num);
        wait (rx_state == RX_IDLE);
        rx_fifo = {};

        wait (rx_fifo.size() == data_num);
    endtask

endmodule
