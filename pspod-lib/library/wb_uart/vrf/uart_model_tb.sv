
// UART model loopback test

module uart_model_tb #(
    parameter SEED = 0
);
    timeunit 1ns;
    timeprecision 1ns;

    localparam T_clk = 20ns;

    logic rx, tx;
    uart_model uart (
        .tx_o (tx),
        .rx_i (rx)
    );

    // loopback!
    assign rx = tx;

    byte tx_buf [$];

    initial begin
        $display("\n%m : Start!\n");
        $urandom(SEED);
        #(100 * T_clk);

        uart.verbose = 1;

        repeat (50) begin
            automatic byte tmp = $urandom;
            tx_buf.push_back(tmp);
            uart.tx_fifo.push_back(tmp);
        end

        wait (uart.rx_fifo.size() == 50);

        foreach (uart.rx_fifo[i]) begin
            if (uart.rx_fifo[i] != tx_buf[i]) begin
                $display("Error! Data mismatch!");
                $stop;
            end
        end

        $display("\n%m : Test passed!\n");

        #(100 * T_clk);
        $stop;
    end

endmodule
