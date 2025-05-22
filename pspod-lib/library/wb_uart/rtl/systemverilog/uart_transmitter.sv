
// Simple UART transmitter
// Frame format - 1 START, 8 DATA (LSB first), 1 STOP
// Author: Алексей Головченко для дефектоскопа

module uart_transmitter (
    input  logic        clk_i      ,
    input  logic        rst_i      ,

    input  logic [15:0] baud_div_i ,
    input  logic  [7:0] data_i     ,
    input  logic        req_i      ,
    output logic        done_o     ,
    output logic        ready_o    ,

    output logic        tx_o
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
        if (state == IDLE && req_i) begin
            baud_div <= baud_div_i;
            baudcnt  <= baud_div_i;
        end else
            baudcnt  <= (baudcnt == '0) ? baud_div : (baudcnt - 1'b1);

    wire baud_tick = (baudcnt == '0);

    // Sample counter

    logic [$clog2(SMPL_N):0] smplcnt;

    always_ff @(posedge clk_i)
        if (state == IDLE && req_i)
            smplcnt <= '0;
        else if (baud_tick) begin
            if (smplcnt == SMPL_N - 1)
                smplcnt <= '0;
            else if (state != IDLE)
                smplcnt <= smplcnt + 1'b1;
        end

    // Data bits counter

    logic [2:0] datcnt;
    always_ff @(posedge clk_i)
        if (state == IDLE && req_i)
            datcnt <= 3'd7;
        else if (state == DATA && smplcnt == SMPL_N - 1 && baud_tick)
            datcnt <= datcnt - 1'b1;

    // State logic

    always_ff @(posedge clk_i or posedge rst_i)
        if (rst_i)
            state <= IDLE;
        else case (state)
            IDLE:
                if (req_i) begin
                    state <= START;
                end

            START:
                if (smplcnt == SMPL_N - 1 && baud_tick) begin
                    state <= DATA;
                end

            DATA:
                if (smplcnt == SMPL_N - 1 && baud_tick) begin
                    if (datcnt == '0)
                        state <= STOP;
                end

            STOP:
                if (smplcnt == SMPL_N - 1 && baud_tick) begin
                    state <= IDLE;
                end

        endcase

    always_ff @(posedge clk_i)
        done_o <= (state == STOP && smplcnt == SMPL_N - 1 && baud_tick);

    assign ready_o = (state == IDLE);

    // Serialazi data

    logic [7:0] data_r;

    wire data_sh_ena = (state == DATA && smplcnt == SMPL_N - 1 && baud_tick);

    always_ff @(posedge clk_i or posedge rst_i)
        if (rst_i)
            data_r <= '1;
        else begin
            if (state == IDLE && req_i)
                data_r <= data_i;
            else if (data_sh_ena)
                data_r <= data_r >> 1;
        end

    always_ff @(posedge clk_i or posedge rst_i)
        if (rst_i)
            tx_o <= '1;
        else if (state == START)
            tx_o <= '0;
        else if (state == DATA)
            tx_o <= data_r[0];
        else
            tx_o <= '1;

endmodule
