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


// (C) 2001-2010 Altera Corporation. All rights reserved.
// Your use of Altera Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License Subscription 
// Agreement, Altera MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the applicable 
// agreement for further details.

// $Id: //acds/main/ip/merlin/altera_reset_controller/altera_tse_reset_synchronizer.v#7 $
// $Revision: #7 $
// $Date: 2010/04/27 $
// $Author: jyeap $

// -----------------------------------------------
// Reset Synchronizer
// -----------------------------------------------
`timescale 1ns / 1ns

module altera_tse_reset_synchronizer
#(
    parameter ASYNC_RESET = 1,
    parameter DEPTH       = 2
)
(
    input   reset_in /* synthesis ALTERA_ATTRIBUTE = "SUPPRESS_DA_RULE_INTERNAL=\"R101,R105\"" */,

    input   clk,
    output  reset_out
);

    // -----------------------------------------------
    // Synchronizer register chain. We cannot reuse the
    // standard synchronizer in this implementation 
    // because our timing constraints are different.
    //
    // Instead of cutting the timing path to the d-input 
    // on the first flop we need to cut the aclr input.
    // 
    // We omit the "preserve" attribute on the final
    // output register, so that the synthesis tool can
    // duplicate it where needed.
    // -----------------------------------------------
    // Please check the false paths setting in TSE SDC
    
    (*preserve*) reg [DEPTH-1:0] altera_tse_reset_synchronizer_chain;
    reg altera_tse_reset_synchronizer_chain_out;

    generate if (ASYNC_RESET) begin

        // -----------------------------------------------
        // Assert asynchronously, deassert synchronously.
        // -----------------------------------------------
        always @(posedge clk or posedge reset_in) begin
            if (reset_in) begin
                altera_tse_reset_synchronizer_chain <= {DEPTH{1'b1}};
                altera_tse_reset_synchronizer_chain_out <= 1'b1;
            end
            else begin
                altera_tse_reset_synchronizer_chain[DEPTH-2:0] <= altera_tse_reset_synchronizer_chain[DEPTH-1:1];
                altera_tse_reset_synchronizer_chain[DEPTH-1] <= 0;
                altera_tse_reset_synchronizer_chain_out <= altera_tse_reset_synchronizer_chain[0];
            end
        end

        assign reset_out = altera_tse_reset_synchronizer_chain_out;
     
    end else begin

        // -----------------------------------------------
        // Assert synchronously, deassert synchronously.
        // -----------------------------------------------
        always @(posedge clk) begin
            altera_tse_reset_synchronizer_chain[DEPTH-2:0] <= altera_tse_reset_synchronizer_chain[DEPTH-1:1];
            altera_tse_reset_synchronizer_chain[DEPTH-1] <= reset_in;
            altera_tse_reset_synchronizer_chain_out <= altera_tse_reset_synchronizer_chain[0];
        end

        assign reset_out = altera_tse_reset_synchronizer_chain_out;
 
    end
    endgenerate

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "HoVSOURGC04ioYPYbYhQ+dAr0NqzvVuBbBuoSNSTaodUtTXAGxV9RDZ3hsZ2j+YeKljE913jbrx7NO82a2X5u3nfkarDH1jEOokOrvdO5PSFY37K21Jeu5Nv2NlWvLYKPFtEZipaJwGMC7tg6DQ3BrVSBQ3nG97mEN7J1ajOWjzrEOMbmpVF0efl8YDEEBZ+Jby/TVrzFR0vMXREO48dD1w8MiIAfo8zURmTHK7imU8+Yc0dIiceEstaUP4dljdQ2xX1hY4tfo69LSFQIzTk6WCo6FBB6u2DAIM8oc0Wa2pY6MIGsgv/YOgn7tT/MOJnI14bzpAimfxPwH/4hJ9fUgWHm0WaJ1goHmageAiL04mOzsjK/xXrWYjUydqLN0uUBFOG/0SbZH9kP1USD7HcbFxYxAIT+BaaVhFF+TeGllY3M2p3r7Pz/GZcfwVnOPWwyG8K7LKIR7QHsZYKdYasgKKdYwnstiePWT4LWPiOac1PWzSwzcfagEx2fbBPaBNDmleJwdKx/iAb+Ajna2GmmsVoMpQa4IcJrdOEg6SJpiV/gKoAKXpc7ofKhkS4wxBpRINxSG8IRpO3goOcLHF8jRL72yBXig7kbTNfktNAYxdjZD4FYugBPiRshvs+V5MK55ld0jcowMBb2wyLO43tZtGMjHGHAOE9COhTrPeuQVx+giG9jNhSq7Mj0coPJw5WywW0xM5vYQpkB34oCHKmqIG4+fduJUGtCmZRA6QojsuLL5j3Z8NbU5jDRf96het6D5yDI0GxyCmJm4YFmRcJBYWM2pKxEUkGFT9Oq/l2kPiRuwqGFEpci6o6CyODbG6gk8Y2wJBk7fEjZ/EleGrh+vozzxPhS3GbHb/aFPubcJYlrYMvHbRDVkwLuxCGoJBe0v9l1Ep6ijLvU9PdTgp7x3aW78FXezAPbbXTCnF37yvfAIlM7Xcn91kS5SV7ZujPHB/FNUuttVuxDa59EVVk2oaRk/xMS0p3zHHb+LXbmWic5Ek3A6HunPc0K6OCDb7I"
`endif