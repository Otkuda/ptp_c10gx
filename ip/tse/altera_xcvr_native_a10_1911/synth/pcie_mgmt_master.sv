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


`timescale 1ps/1ps

// Revision 2.0
module pcie_mgmt_master #(
    parameter CLOCKS_PER_SECOND = 125000000,  // Used for time calculations
    parameter PIO_OUT_SIZE      = 8,          // Width of PIO output port
    parameter PIO_IN_SIZE       = 8,          // Width of PIO input port
    parameter [PIO_OUT_SIZE-1:0] PIO_OUT_INIT_VALUE = 0,  // Initial value for pio_out registers
    parameter MEM_DEPTH         = 8,
    parameter ROM_DEPTH         = 512         // Depth of command ROM
//  parameter INIT_FILE_NAME    = ""          // If specified, ROM will be initialized from file using $readmemh
  ) (
  input                           clk,
  input                           reset,

  output  reg                     av_write,
  output  reg                     av_read,
  output  reg [30:0]              av_address,
  output  reg [31:0]              av_writedata,
  input       [31:0]              av_readdata,
  input                           av_waitrequest,

  output  reg [PIO_OUT_SIZE-1:0]  pio_out,
  input       [ PIO_IN_SIZE-1:0]  pio_in
);

import pcie_mgmt_functions_h::*;
import pcie_mgmt_commands_h::*;
import pcie_mgmt_program::*;


//localparam  LOAD_FROM_FILE = (INIT_FILE_NAME == "") ? 0 : 1;
//localparam  FILETYPE="hex";
localparam  ADDR_WIDTH = clogb2(ROM_DEPTH);

reg   [ROM_WIDTH-1:0]   rom [0:(ROM_DEPTH-1)];  // Command storage ROM
wire  [ADDR_WIDTH-1:0]  rom_address;
wire                    rom_read;
reg   [ ROM_WIDTH-1:0]  rom_data;

// PCIE Management Functions Variables
prom_struct_t           prom_set;

//*********************************************************************
//************************ Command ROM ********************************
// Output addressed ROM contents
always @ (posedge clk)
  if(rom_read)
    rom_data  <= rom[rom_address];

//********************** End Command ROM ******************************
//*********************************************************************


pcie_mgmt_cpu #(
    .PIO_OUT_SIZE       (PIO_OUT_SIZE),
    .PIO_IN_SIZE        (PIO_IN_SIZE ),
    .PIO_OUT_INIT_VALUE (PIO_OUT_INIT_VALUE),
    .ROM_DEPTH          (ROM_DEPTH   ),
    .MEM_DEPTH          (MEM_DEPTH)
    ) mgmt_cpu_inst (
  .clk            (clk            ),
  .reset          (reset          ),

  .av_write       (av_write       ),
  .av_read        (av_read        ),
  .av_address     (av_address     ),
  .av_writedata   (av_writedata   ),
  .av_readdata    (av_readdata    ),
  .av_waitrequest (av_waitrequest ),

  .rom_address    (rom_address    ),
  .rom_read       (rom_read       ),
  .rom_data       (rom_data       ),

  .pio_out        (pio_out        ), .pio_in         (pio_in         )
);


//generate if(LOAD_FROM_FILE == 0) begin : load_ram
  integer i;
  initial begin
    prom_set.clocks_per_second = CLOCKS_PER_SECOND;
    pre_process(prom_set);  // Pre process
    pcie_mgmt_program(prom_set);
    post_process(prom_set); // Post process program
    // Copy program from temporary prog_rom to rom
    for(i=0;i<ROM_DEPTH;i=i+1) begin
      rom[i] = prom_set.prog_rom[i];
    end
  end
//end
//
//else begin
//  if(FILETYPE == "hex") begin
//    initial begin
//      $readmemh(INIT_FILE_NAME, rom);
//    end
//  end else begin
//    initial begin
//      $readmemb(INIT_FILE_NAME, rom);
//    end
//  end
//end
//endgenerate

// Undefine previously defined macros
`ifdef MGMT_UNDEF
  `undef MGMT_PROGRAM_TASK
  `undef MGMT_UNDEF
`endif

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "opdVy43h6iNiR8xG87bmerDaXcSC3FhyOyT1oNCpTIictLSg3ZSNlowtASKN8wYiV5fUXl7Ly4t+I7vTfsM5xOKbUZpA1P2Ve34oRG6KIRIuRijDsCmTFF10umgF3/A8qX6Rbu8BsP0lO4HOGX6VKWZ8M8oaT1gDUFdLpzF4fAfvJXd+fc3EDkYIeu2yHWI4JH9ahX9IbTgnN93MN175TqIVeNuWyfpZpsvodCyAubMptyuE0aNARBGcJwtjR4UfQ6dCjeAvK2bm8lFzbtlMpmjkqGKc3LN9KbFxGLgmXjs9oE5TGSzsDiFAZ8WM2a1e52kzllROYDlzfSTc0NTUKZyhZuU8ooqgZfi7siagS8XGvMCnyxrpUYsUuDbbRj+3mE7vm1VMXOqJjDOgdYHerq8/Fba8aVx/nPtJGxbw7ScHCYU+5MqjNZlnon5W+1g5kgrNgXqnUZmanLbHwuPYnCBZlD8u40Cib9ZzUlc0PfmAjHQ/lW7BnMBKd9l9JDlpyIHL/FaqPcOE87vsZSF1lWS77MwCcH2fTyCixxVq/uM5Y82n2Qv/qVEw9kyZlEx8H/axbPYCXeosuPBdETzxTESdZusozeA5Nm0JQduCwoF+phl4KBdvtEa4v0wpJT4GooS7ZYNMJ/44cxH6Wm7ria7MdvzKR2zaNTM8xf2/bUuYmE6Cm7KJAanb57dIeDLYZx6bhqFJMb0gMInUaFM2hGHGbHNPVX03kYjxdnHoqdDhPLymvRZrGSTl3o2yzvAjxSymsX+DmWiA7qlueS1V6qJjBmXygnQKx8MlA47j/jdqx2u2sq0QQZLatg662FtyPX5EpAcvCNxKtoYUUw/TKPECitd/MLaglnL2tLrHhB0Dr1Prf/KTNLJtSVGCXnrfGU2MsXVxncg6NNE0HIv0WVGlkD1i2oNQJWNJxau0dks8MNq7RlPV8qRpJFWKelO9AZ8BIfKq7UPKAbXJi1VMBwhxli5NU+bxqF9tlSl6PB1cNj1J4GiR8X16at7mfBno"
`endif