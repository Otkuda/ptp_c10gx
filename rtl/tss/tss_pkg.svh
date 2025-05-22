//--------------------------------------------------------------------
//    Author:
//        Dmitry Ryabikov, dmitry.ryabikov@spbpu.com
//
//    Description:
//        Address, Values, Commands and Type definitions for TSS controller
//--------------------------------------------------------------------

`ifndef TSS_PKG_SVH
`define TSS_PKG_SVH

package tss_pkg;
    
    // Address Registers
    parameter SLICE_LENGTH_ADR    = 32'h03000200; // 0x10
    parameter FRAME_LENGTH_ADR    = 32'h03000204; // 0x11
    parameter BATCH_LENGTH_ADR    = 32'h03000208; // 0x12
    parameter SEQUENCE_LENGTH_ADR = 32'h0300020C; // 0x13
    parameter BATCH_INTERVAL_ADR  = 32'h03000210; // 0x14
    parameter NEXT_FRAME_ADR      = 32'h03000214; // 0x15
    parameter LAST_FRAME_ADR      = 32'h03000218; // 0x16
    parameter DELTA_TIME_ADR      = 32'h0300021C; // 0x17
    parameter CONTROL_ADR         = 32'h03000220; // 0x18
    parameter USER_DELTA_TIME_ADR = 32'h03000224; // 0x19

    // Default Registers Values
    parameter SLICE_LENGTH_VALUE    = 32'h04; // 0x04
    parameter FRAME_LENGTH_VALUE    = 32'h04; // 0x04
    parameter BATCH_LENGTH_VALUE    = 32'h00; // 0x00
    parameter SEQUENCE_LENGTH_VALUE = 32'h00; // 0x00
    parameter BATCH_INTERVAL_VALUE  = 32'h04; // 0x04
    parameter NEXT_FRAME_VALUE      = 32'h00; // 0x00
    parameter LAST_FRAME_VALUE      = 32'h08; // 0x08
    parameter DELTA_TIME_VALUE      = 68'h300; // 0x03 - Const network latency
    parameter USER_DELTA_TIME_VALUE = 68'h00; // 0x00 - Custom latency defined by user
    
    // Registers Width
    parameter TAI_WIDTH       = 40;
    parameter CNT_NS_WIDTH    = 28;
    parameter REG_ADDR_WIDTH  = 5;
    parameter REG_DATA_WIDTH  = 32;
    parameter HEADER_WIDTH    = 8;
    parameter TIMESTAMP_WIDTH = TAI_WIDTH + CNT_NS_WIDTH; // 68
    parameter PAYLOAD_WIDTH   = REG_DATA_WIDTH * 6; // 192
    parameter COMMAND_WIDTH   = TIMESTAMP_WIDTH + PAYLOAD_WIDTH + HEADER_WIDTH; // 268

    // Headers
    parameter START_HEADER    = 1;
    parameter STOP_HEADER     = 2;
    parameter CONTINUE_HEADER = 4;
    parameter ABORT_HEADER    = 8;

    // Type definitions
    typedef struct packed {
        logic [REG_DATA_WIDTH-1:0 ] slice_length;
        logic [REG_DATA_WIDTH-1:0 ] frame_length;
        logic [REG_DATA_WIDTH-1:0 ] batch_length;
        logic [REG_DATA_WIDTH-1:0 ] sequence_length;
        logic [REG_DATA_WIDTH-1:0 ] batch_interval;
        logic [REG_DATA_WIDTH-1:0 ] next_frame;
        logic [REG_DATA_WIDTH-1:0 ] last_frame;
        logic [REG_DATA_WIDTH-1:0 ] control;
        logic [TIMESTAMP_WIDTH-1:0] delta_time;
        logic [TIMESTAMP_WIDTH-1:0] user_delta_time;
    } register_values;

    typedef struct packed {
        logic [REG_DATA_WIDTH-1:0 ] last_frame;
        logic [REG_DATA_WIDTH-1:0 ] batch_interval;
        logic [REG_DATA_WIDTH-1:0 ] sequence_length;
        logic [REG_DATA_WIDTH-1:0 ] batch_length;
        logic [REG_DATA_WIDTH-1:0 ] frame_length;
        logic [REG_DATA_WIDTH-1:0 ] slice_length;
        logic [TIMESTAMP_WIDTH-1:0] timestamp;
        logic [HEADER_WIDTH-1:0   ] header;
    } command_values;

    typedef struct packed {
        logic [REG_DATA_WIDTH-1:0] slice_length_cnt;
        logic [REG_DATA_WIDTH-1:0] frame_length_cnt;
        logic [REG_DATA_WIDTH-1:0] batch_length_cnt;
        logic [REG_DATA_WIDTH-1:0] batch_interval_cnt;
        logic [REG_DATA_WIDTH-1:0] seq_length_cnt;
    } com_gen_savestate;

endpackage

`endif
