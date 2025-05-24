//--------------------------------------------------------------------
//    Author:
//        Dmitry Ryabikov, dmitry.ryabikov@spbpu.com
//
//    Description:
//        Serialize command from computer to 1 byte for AXI-Stream interface
//
//    Ports:
//        clk       - system clock
//        arst      - asynchronous reset
//        command_i - commands form computer
//        m_axis    - AXI-Stream master interface
//--------------------------------------------------------------------


import tss_pkg::*;

module serializer (
    input logic                     clk,
    input logic                     arst,
    input logic [COMMAND_WIDTH-1:0] command_i,
    
    output logic [7:0] tss_axis_tdata,
    output logic       tss_axis_tvalid,
    input  logic       tss_axis_tready,
    output logic       tss_axis_tlast
);

    localparam COM_WIDTH_DIV = (COMMAND_WIDTH/8) * 8; // 264
    localparam TM_WIDTH_DIV  = ((TIMESTAMP_WIDTH + HEADER_WIDTH)/8) * 8; // 72  

    logic [$clog2(COMMAND_WIDTH)-1:0] command_cnt;
    logic [COMMAND_WIDTH-1:0        ] tmp;

    enum logic [2:0] {
        IDLE                          = 3'b000,
        HEADER_CHECK                  = 3'b001,
        START_OF_SEQ_COMMAND_TRANSMIT = 3'b010,
        STOP_OF_SEQ_COMMAND_TRANSMIT  = 3'b011,
        LAST                          = 3'b100,
        STOP                          = 3'b101
    } state = IDLE;

    always_ff @(posedge clk or posedge arst) begin
        if (arst) begin
            state <= IDLE;
        end
        else begin
            case (state)
                IDLE: if (command_i[HEADER_WIDTH-1:0] != 0) begin
                    tmp   <= command_i;
                    state <= HEADER_CHECK;
                end
                HEADER_CHECK: begin
                    if (tss_axis_tready) begin
                        if (tmp[HEADER_WIDTH-1:0] == START_HEADER)         state <= START_OF_SEQ_COMMAND_TRANSMIT;
                        else if (tmp[HEADER_WIDTH-1:0] == STOP_HEADER)     state <= STOP_OF_SEQ_COMMAND_TRANSMIT;
                        else if (tmp[HEADER_WIDTH-1:0] == CONTINUE_HEADER) state <= STOP_OF_SEQ_COMMAND_TRANSMIT;
                        else if (tmp[HEADER_WIDTH-1:0] == ABORT_HEADER)    state <= LAST;
                        else                                               state <= IDLE;
                    end
                end
                START_OF_SEQ_COMMAND_TRANSMIT: if (tss_axis_tready) begin
                    if (command_cnt >= COM_WIDTH_DIV - HEADER_WIDTH) state <= LAST;
                end
                STOP_OF_SEQ_COMMAND_TRANSMIT: if (tss_axis_tready) begin
                    if (command_cnt >= TM_WIDTH_DIV - HEADER_WIDTH) state <= LAST;
                end
                LAST: if (tss_axis_tready) begin
                    state <= STOP;
                end
                STOP: begin
                    tmp   <= 0;
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

    always_comb begin
        tss_axis_tlast  = (state == LAST);
        tss_axis_tvalid = (state == HEADER_CHECK || state == START_OF_SEQ_COMMAND_TRANSMIT ||
                         state == STOP_OF_SEQ_COMMAND_TRANSMIT || state == LAST);
        case (state)
            HEADER_CHECK: tss_axis_tdata = tmp[command_cnt+:HEADER_WIDTH];
            START_OF_SEQ_COMMAND_TRANSMIT: tss_axis_tdata = tmp[command_cnt+:HEADER_WIDTH];
            STOP_OF_SEQ_COMMAND_TRANSMIT:  tss_axis_tdata = tmp[command_cnt+:HEADER_WIDTH];
            LAST: tss_axis_tdata = (tmp[7:0] != 8'h08) ? {4'h0, tmp[command_cnt+:HEADER_WIDTH/2]} : 8'h0;
            STOP: tss_axis_tdata = 0;
            default: tss_axis_tdata = 0;
        endcase
    end

    always_ff @(posedge clk or posedge arst) begin
        if (arst) begin
            command_cnt <= 0;
        end else begin
            if (tss_axis_tready & tss_axis_tvalid) begin
                command_cnt <= command_cnt + HEADER_WIDTH;
            end if (state == LAST && (command_cnt == COM_WIDTH_DIV || command_cnt == TM_WIDTH_DIV || command_cnt == 4'h8)) begin
                command_cnt <= 0;
            end
        end
    end

endmodule
