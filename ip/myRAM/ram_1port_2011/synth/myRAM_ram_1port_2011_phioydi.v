// (C) 2001-2024 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.



// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on
module  myRAM_ram_1port_2011_phioydi  (
    address,
    byteena,
    clock,
    data,
    wren,
    q);

    input  [8:0]  address;
    input  [3:0]  byteena;
    input    clock;
    input  [31:0]  data;
    input    wren;
    output [31:0]  q;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_off
`endif
    tri1 [3:0]  byteena;
    tri1     clock;
`ifndef ALTERA_RESERVED_QIS
// synopsys translate_on
`endif

    wire [31:0] sub_wire0;
    wire [31:0] q = sub_wire0[31:0];


    // Instantiate In System Memory Content Editor IP 
    wire reset_out;
    wire [8:0] ismce_addr;
    wire [3:0]ismce_byteena;
    wire [31:0] ismce_wdata;
    wire ismce_wren;
    wire ismce_rden;
    wire [31:0] ismce_rdata;
    wire ismce_waitrequest;
    wire tck_usr;

    //intel_mce_inst intel_mce_component (
    myRAM_ram_1port_intel_mce_2011_i6ey5bq  intel_mce_component (
        .clock0           (clock            ),
        .tck_usr          (tck_usr          ),
        .reset_out        (reset_out        ),
        .ismce_addr       (ismce_addr       ),
        .ismce_byteena    (ismce_byteena    ),
        .ismce_wdata      (ismce_wdata      ),
        .ismce_wren       (ismce_wren       ),
        .ismce_rden       (ismce_rden       ),
        .ismce_rdata      (ismce_rdata      ),
        .ismce_waitrequest(ismce_waitrequest) 
    );    
    assign ismce_waitrequest = 1'b0;    

    altera_syncram  altera_syncram_component (
                .address_a (address),
                .byteena_a (byteena),
                .clock0 (clock),
                .data_a (data),
                .wren_a (wren),
                .q_a (sub_wire0),
                .aclr0 (1'b0),
                .aclr1 (1'b0),
                .address2_a (1'b1),
                .address2_b (1'b1),
                .address_b (ismce_addr),
                .addressstall_a (1'b0),
                .addressstall_b (1'b0),
                .byteena_b (ismce_byteena),
                .clock1 (tck_usr),
                .clocken0 (1'b1),
                .clocken1 (1'b1),
                .clocken2 (1'b1),
                .clocken3 (1'b1),
                .data_b (ismce_wdata),
                .eccencbypass (1'b0),
                .eccencparity (8'b0),
                .eccstatus ( ),
                .q_b (ismce_rdata),
                .rden_a (1'b1),
                .rden_b (1'b1),
                .sclr (1'b0),
                .wren_b (ismce_wren));
    defparam
        altera_syncram_component.byte_size  = 8,
        altera_syncram_component.width_byteena_a  = 4,
        altera_syncram_component.clock_enable_input_a  = "BYPASS",
        altera_syncram_component.clock_enable_output_a  = "BYPASS",
        altera_syncram_component.intended_device_family  = "Cyclone 10 GX",
        altera_syncram_component.lpm_type  = "altera_syncram",
        altera_syncram_component.numwords_a  = 512,
        altera_syncram_component.operation_mode  = "BIDIR_DUAL_PORT",
        altera_syncram_component.outdata_aclr_a  = "NONE",
        altera_syncram_component.outdata_sclr_a  = "NONE",
        altera_syncram_component.outdata_reg_a  = "UNREGISTERED",
        altera_syncram_component.enable_force_to_zero  = "FALSE",
        altera_syncram_component.power_up_uninitialized  = "FALSE",
        altera_syncram_component.read_during_write_mode_port_a  = "NEW_DATA_NO_NBE_READ",
        altera_syncram_component.widthad_a  = 9,
        altera_syncram_component.width_a  = 32,
        altera_syncram_component.width_byteena_b  = 4,
        altera_syncram_component.clock_enable_input_b  = "BYPASS",
        altera_syncram_component.clock_enable_output_b  = "BYPASS",
        altera_syncram_component.numwords_b  = 512,
        altera_syncram_component.outdata_aclr_b  = "NONE",
        altera_syncram_component.outdata_sclr_b  = "NONE",
        altera_syncram_component.outdata_reg_b  = "UNREGISTERED",
        altera_syncram_component.read_during_write_mode_port_b  = "NEW_DATA_NO_NBE_READ",
        altera_syncram_component.widthad_b  = 9,
        altera_syncram_component.width_b  = 32;



endmodule

