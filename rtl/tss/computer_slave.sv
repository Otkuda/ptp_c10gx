//--------------------------------------------------------------------
//    Author:
//        Dmitry Ryabikov, dmitry.ryabikov@spbpu.com
//
//    Description:
//        interface between computer and TSS controller TX module
//
//    Ports:
//        clk           - system clock
//        arst          - asynchronous reset
//        write_i       - signal from computer to write data into registers
//        timer_valid_i - valid signal from timer
//        timer_i       - timer input
//        reg_data_i    - data from computer to registers
//        reg_addr_i    - registers address from computer    
//        reg_data_o    - data from registers to computer
//--------------------------------------------------------------------

import tss_pkg::*;

module computer_slave (
    input  logic                       clk,
    input  logic                       arst,
    input  logic                       wbs_we_i,
    input  logic [31:0]                wbs_addr_i,
    input  logic [31:0]                wbs_data_i,
    output logic [31:0]                wbs_data_o,
    input  logic                       wbs_stb_i,
    output logic                       wbs_ack_o, 
    input  logic                       timer_valid_i,
    input  logic [TIMESTAMP_WIDTH-1:0] timer_i,
    output logic [COMMAND_WIDTH-1:0]   command_o
);

    register_values reg_val;

    localparam START     = 8'b0000_0001;
    localparam STOP      = 8'b0000_0010;
    localparam CONTINUE  = 8'b0000_0100;
    localparam ABORT     = 8'b0000_1000;

    always_ff @(posedge clk or posedge arst) begin
        if (arst | ~timer_valid_i) begin
            reg_val.slice_length    <= SLICE_LENGTH_VALUE;
            reg_val.frame_length    <= FRAME_LENGTH_VALUE; 
            reg_val.batch_length    <= BATCH_LENGTH_VALUE;
            reg_val.sequence_length <= SEQUENCE_LENGTH_VALUE;
            reg_val.batch_interval  <= BATCH_INTERVAL_VALUE;
            reg_val.next_frame      <= NEXT_FRAME_VALUE;
            reg_val.last_frame      <= LAST_FRAME_VALUE;
            reg_val.delta_time      <= DELTA_TIME_VALUE;
            reg_val.control         <= 0;
            reg_val.user_delta_time <= USER_DELTA_TIME_VALUE;
            wbs_data_o              <= 0;
        end else begin
          if (wbs_stb_i) begin
            // Write logic
            if (wbs_we_i) begin
              case (wbs_addr_i)
                SLICE_LENGTH_ADR:    reg_val.slice_length    <= wbs_data_i;
                FRAME_LENGTH_ADR:    reg_val.frame_length    <= wbs_data_i;
                BATCH_LENGTH_ADR:    reg_val.batch_length    <= wbs_data_i;
                SEQUENCE_LENGTH_ADR: reg_val.sequence_length <= wbs_data_i;
                BATCH_INTERVAL_ADR:  reg_val.batch_interval  <= wbs_data_i;
                // NEXT_FRAME:      reg_val.next_frame      <= reg_data_i;
                LAST_FRAME_ADR:      reg_val.last_frame      <= wbs_data_i;
                // DELTA_TIME:      reg_val.delta_time      <= reg_data_i;
                CONTROL_ADR:         reg_val.control         <= wbs_data_i;
                USER_DELTA_TIME_ADR: reg_val.user_delta_time <= wbs_data_i;
              endcase
            end
            else begin
              
              // Read logic
              case (wbs_addr_i)
                SLICE_LENGTH_ADR:    wbs_data_o <= reg_val.slice_length;
                FRAME_LENGTH_ADR:    wbs_data_o <= reg_val.frame_length;
                BATCH_LENGTH_ADR:    wbs_data_o <= reg_val.batch_length;
                SEQUENCE_LENGTH_ADR: wbs_data_o <= reg_val.sequence_length;
                BATCH_INTERVAL_ADR:  wbs_data_o <= reg_val.batch_interval;
                NEXT_FRAME_ADR:      wbs_data_o <= reg_val.next_frame;
                LAST_FRAME_ADR:      wbs_data_o <= reg_val.last_frame;
                DELTA_TIME_ADR:      wbs_data_o <= reg_val.delta_time;
                // CONTROL: reg_data_o <= reg_val.control;
                USER_DELTA_TIME_ADR: wbs_data_o <= reg_val.user_delta_time;
                default:             wbs_data_o <= 0;
              endcase
            end
          end else begin
            // Autoreset
            if (reg_val.control != 0) reg_val.control <= 0;
          end
        end
    end

    always_ff @(posedge clk) begin
      if (arst)
        wbs_ack_o <= 0;
      else if (wbs_ack_o)
        wbs_ack_o <= 0;
      else if (wbs_stb_i)
        wbs_ack_o <= 1;
      else
        wbs_ack_o <= 0;
    end

    // Command generation
    always_ff @(posedge clk or posedge arst) begin
        if (arst | ~timer_valid_i) command_o <= 0;
        else if (~wbs_we_i) begin
            case (reg_val.control)
                START_HEADER:     command_o <= |reg_val.user_delta_time ?
                                                {reg_val.last_frame, reg_val.batch_interval, reg_val.sequence_length, reg_val.batch_length,
                                                reg_val.frame_length, reg_val.slice_length, timer_i + reg_val.user_delta_time, START} :
                                                {reg_val.last_frame, reg_val.batch_interval, reg_val.sequence_length, reg_val.batch_length,
                                                reg_val.frame_length, reg_val.slice_length, timer_i + reg_val.delta_time, START};
                STOP_HEADER:      command_o <= |reg_val.user_delta_time ? 
                                                {192'h0, timer_i + reg_val.user_delta_time, STOP} : {192'h0, timer_i + reg_val.delta_time, STOP};
                CONTINUE_HEADER:  command_o <= |reg_val.user_delta_time ? 
                                                {192'h0, timer_i + reg_val.user_delta_time, CONTINUE} : {192'h0, timer_i + reg_val.delta_time, CONTINUE};
                ABORT_HEADER:     command_o <= {260'h0, ABORT};
                default:          command_o <= 0;
            endcase
        end
    end

endmodule
