
// Simple UART receiver
// Frame format - 1 START, 8 DATA (LSB first), 1 STOP
// Author: Алексей Головченко для дефектоскопа

module uart_receiver #(
    // "0" - 2 stage, "1" - 3 stage
    parameter bit SYNC_STAGES   = 1'b1 ,
    // "0" - not used, "1" - 4 from 7
    parameter bit MAJORITY_VOTE = 1'b1
)(
    input  logic        clk_i      ,
    input  logic        rst_i      ,
    input  logic        rx_i       ,
    input  logic [15:0] baud_div_i ,

    output logic [7:0]  data_o     ,
    output logic        ready_o
);

    logic rx_fltrd;
    uart_receiver_filter #(
        SYNC_STAGES, MAJORITY_VOTE
    ) rx_filter (
        .rx_o (rx_fltrd),
        .*
    );

    localparam [4:0] SMPL_N = 16;

    enum bit [1:0] {
        IDLE  ,
        START ,
        DATA  ,
        STOP
    } state;

    // Baudrate generator
    // NB. SMPL_N times faster than real baudrate!

    logic [15:0] baud_div ;
    logic [15:0] baudcnt  ;

    always_ff @(posedge clk_i)
        if (state == IDLE && !rx_fltrd) begin
            baud_div <= baud_div_i;
            baudcnt  <= baud_div_i;
        end
        else if (state != IDLE)
            baudcnt <= (baudcnt == '0) ? baud_div : (baudcnt - 1'b1);

    wire baud_tick = (baudcnt == '0);

    // Sample counter

    logic [$clog2(SMPL_N):0] smplcnt;

    always_ff @(posedge clk_i)
        if (state == IDLE && !rx_fltrd)
            smplcnt <= '0;
        else if (baud_tick) begin
            if (state == START && smplcnt == SMPL_N / 2 - 1)
                smplcnt <= '0;
            else if (state == DATA && smplcnt == SMPL_N - 1)
                smplcnt <= '0;
            else if (state == STOP && smplcnt == SMPL_N + SMPL_N / 2 - 1)
                smplcnt <= '0;
            else if (state != IDLE)
                smplcnt <= smplcnt + 1'b1;
        end

    wire rd_data_ena = (state == DATA && smplcnt == SMPL_N - 1 && baud_tick);

    // Data bits counter

    logic [2:0] datcnt;
    always_ff @(posedge clk_i)
        if (state == IDLE && !rx_fltrd)
            datcnt <= 3'd7;
        else if (state == DATA && smplcnt == SMPL_N - 1 && baud_tick)
            datcnt <= datcnt - 1'b1;

    // State logic

    always_ff @(posedge clk_i or posedge rst_i)
        if (rst_i)
            state <= IDLE;
        else case (state)
            IDLE:
                if (!rx_fltrd) begin
                    state <= START;
                end

            START:
                if (smplcnt == SMPL_N / 2 - 1 && baud_tick) begin
                    state <= DATA;
                end

            DATA:
                if (smplcnt == SMPL_N - 1 && datcnt == '0 && baud_tick) begin
                    state <= STOP;
                end

            STOP:
                if (smplcnt == SMPL_N - 1) begin
                    state <= IDLE;
                end
        endcase

    // Read serial data

    always_ff @(posedge clk_i)
        if (rd_data_ena)
            data_o <= {rx_fltrd, data_o[7:1]};

    always_ff @(posedge clk_i)
        ready_o <= (state == DATA && smplcnt == SMPL_N - 1 && datcnt == '0 && baud_tick);

endmodule

module uart_receiver_filter #(
    // "0" - 2 stage  , "1" - 3 stage
    parameter bit SYNC_STAGES   = 1'b1 ,
    // "0" - not used , "1" - 4 from 7
    parameter bit MAJORITY_VOTE = 1'b1
)(
    input  logic clk_i ,
    input  logic rst_i ,
    input  logic rx_i  ,
    output logic rx_o
);

    // Synchronize RX signal
    localparam SYNC_W = SYNC_STAGES ? 3 : 2;
    logic [SYNC_W - 1:0] rx_sync;

    always_ff @(posedge clk_i)
        rx_sync <= (rx_sync << 1) | rx_i;


    // Filtering RX using majority vote
    generate
        if (MAJORITY_VOTE) begin : use_mv
            logic [6:0] rx_buf;
            logic [2:0] popcnt;

            always_ff @(posedge clk_i or posedge rst_i)
                if (rst_i)
                    rx_buf <= '1;
                else
                    rx_buf <= (rx_buf << 1) | rx_sync[SYNC_W - 1];

            always_comb begin
                popcnt = '0;
                for (int i = 0; i < 7; ++i)
                    popcnt += rx_buf[i];
            end

            assign rx_o = popcnt[2];
        end
        else begin : not_use_mv
            assign rx_o = rx_sync[SYNC_W - 1];
        end
    endgenerate

endmodule
