//--------------------------------------------------------------------
//    Author:
//        Dmitry Ryabikov, dmitry.ryabikov@spbpu.com
//
//    Description:
//        Top level module
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
//        command_o     - command output
//        m_axis        - AXI-Stream master interface
//--------------------------------------------------------------------

import tss_pkg::*;

module tss_controller_tx (
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
    
    output logic [7:0] tss_axis_tdata,
    output logic       tss_axis_tvalid,
    input  logic       tss_axis_tready,
    output logic       tss_axis_tlast
);

    logic [COMMAND_WIDTH-1:0] command;

    computer_slave slave_inst (
        .clk           (clk          ),
        .arst          (arst         ),
        .wbs_we_i      (wbs_we_i     ),
        .wbs_addr_i    (wbs_addr_i   ),
        .wbs_data_i    (wbs_data_i   ),
        .wbs_data_o    (wbs_data_o   ),
        .wbs_stb_i     (wbs_stb_i    ),
        .wbs_ack_o     (wbs_ack_o    ),
        .timer_valid_i (timer_valid_i),
        .timer_i       (timer_i      ),
        .command_o     (command      )
    );

    serializer serializer_inst (
        .clk       (clk    ),
        .arst      (arst   ),
        .command_i (command),
        .tss_axis_tdata(tss_axis_tdata),
        .tss_axis_tvalid(tss_axis_tvalid),
        .tss_axis_tready(tss_axis_tready),
        .tss_axis_tlast(tss_axis_tlast)
    );

endmodule
