`timescale 1ns/1ps

module ptp_rtc #(
    parameter PPS_LEN = 20 // PPS active level duration in clk cycles
) (
    input  wire clk,
    input  wire rst,
    // Period setup
    input  wire        i_period_ld,
    input  wire [31:0] i_period_nsec,
    // Direct setup
    input  wire        i_time_ld,
    input  wire [31:0] i_time_sec,
    input  wire [31:0] i_time_nsec,
    // Offset input
    input  wire        i_offset_ld,
    input  wire [31:0] i_offset_nsec,
    // Adjustment input
    input  wire        i_adj_ld,
    input  wire [ 7:0] i_adj_cnt,
    input  wire [31:0] i_adj_nsec,
    input  wire [31:0] i_adj_nsec_f,
    // Internal time output
    output wire [47:0] o_int_time_sec,
    output wire [31:0] o_int_time_nsec,

    output wire        o_pps,
    // PTP time output
    output wire [47:0] o_ptp_time_sec,
    output wire [31:0] o_ptp_time_nsec
);

localparam NSEC_VAL = 1_000_000_000; 

endmodule
