
// Author: Алексей Головченко для дефектоскопа
// Wishbone B3

`include "wb_if_defs.svh"

interface wb_if (
    input wire clk,
    input wire rst
);
    logic [`WB_DAT_MAX_WIDTH-1:0] dat_s2m ;
    logic [`WB_DAT_MAX_WIDTH-1:0] dat_m2s ;

    logic                         cyc     ;
    logic                         stb     ;
    logic                         we      ;
    logic [`WB_ADR_MAX_WIDTH-1:0] adr     ;
    logic [`WB_SEL_MAX_WIDTH-1:0] sel     ;

    logic                         ack     ;
    logic                         err     ;
    logic                         rty     ;

    logic                   [2:0] cti     ;
    logic                   [1:0] bte     ;

    // Unused signals (Wishbone B4)
    // logic                         stall ;
    // logic                         lock  ;
    // logic [`WB_TGA_MAX_WIDTH-1:0] tga   ;
    // logic [`WB_TGC_MAX_WIDTH-1:0] tgc   ;
    // logic [`WB_TGD_MAX_WIDTH-1:0] tgd_s2m ;
    // logic [`WB_TGD_MAX_WIDTH-1:0] tgd_m2s ;

    modport mst (
        input  dat_s2m ,
        output dat_m2s ,
        output cyc     ,
        output stb     ,
        output we      ,
        output adr     ,
        output sel     ,
        input  ack     ,
        input  err     ,
        input  rty     ,
        output cti     ,
        output bte
    );

    modport slv (
        output dat_s2m ,
        input  dat_m2s ,
        input  cyc     ,
        input  stb     ,
        input  we      ,
        input  adr     ,
        input  sel     ,
        output ack     ,
        output err     ,
        output rty     ,
        input  cti     ,
        input  bte
    );

    modport mon (
        input  dat_s2m ,
        input  dat_m2s ,
        input  cyc     ,
        input  stb     ,
        input  we      ,
        input  adr     ,
        input  sel     ,
        input  ack     ,
        input  err     ,
        input  rty     ,
        input  cti     ,
        input  bte
    );

endinterface
