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


// -------------------------------------------------------------------------
// -------------------------------------------------------------------------
//
// Revision Control Information
//
// $RCSfile: altera_tse_alt2gxb_aligned_rxsync.v,v $
// $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/RTL/strxii_pcs/verilog/altera_tse_alt2gxb_aligned_rxsync.v,v $
//
// $Revision: #1 $
// $Date: 2024/08/01 $
// Check in by : $Author: psgswbuild $
// Author      : Siew Kong NG
//
// Project     : Triple Speed Ethernet - 1000 BASE-X PCS
//
// Description : 
//
// RX_SYNC alignment for Alt2gxb, Alt4gxb

// 
// ALTERA Confidential and Proprietary
// Copyright 2007 (c) Altera Corporation
// All rights reserved
//
// -------------------------------------------------------------------------
// -------------------------------------------------------------------------

`timescale 1ns/1ns
module altera_tse_gxb_aligned_rxsync (

  input clk,
  input reset,

  input [7:0] alt_dataout,
  input alt_sync,
  input alt_disperr,
  input alt_ctrldetect,
  input alt_errdetect,
  input alt_rmfifodatadeleted,
  input alt_rmfifodatainserted,
  input alt_runlengthviolation,
  input alt_patterndetect,
  input alt_runningdisp,

  output reg [7:0] altpcs_dataout,
  output altpcs_sync,
  output reg altpcs_disperr,
  output reg altpcs_ctrldetect,
  output reg altpcs_errdetect,
  output reg altpcs_rmfifodatadeleted,
  output reg altpcs_rmfifodatainserted,
  output reg altpcs_carrierdetect) ;
  parameter DEVICE_FAMILY         = "ARRIAGX";    //  The device family the the core is targetted for. 

  //-------------------------------------------------------------------------------
  // intermediate wires


  //reg altpcs_dataout

  // pipelined 1
  reg [7:0] alt_dataout_reg1;
  reg alt_sync_reg1;
  reg alt_sync_reg2;
  reg alt_disperr_reg1;
  reg alt_ctrldetect_reg1;
  reg alt_errdetect_reg1;
  reg alt_rmfifodatadeleted_reg1;
  reg alt_rmfifodatainserted_reg1;
  reg alt_patterndetect_reg1;
  reg alt_runningdisp_reg1;
  reg alt_runlengthviolation_latched;
  //-------------------------------------------------------------------------------

  always @(posedge reset or posedge clk)
    begin
        if (reset == 1'b1)
            begin
                // pipelined 1
                alt_dataout_reg1            <= 8'h0;
                alt_sync_reg1               <= 1'b0;
                alt_disperr_reg1            <= 1'b0;
                alt_ctrldetect_reg1         <= 1'b0;
                alt_errdetect_reg1          <= 1'b0;
                alt_rmfifodatadeleted_reg1  <= 1'b0;
                alt_rmfifodatainserted_reg1 <= 1'b0;
                alt_patterndetect_reg1      <= 1'b0;
                alt_runningdisp_reg1        <= 1'b0;
            end
        else
            begin
                // pipelined 1
                alt_dataout_reg1            <= alt_dataout;
                alt_sync_reg1               <= alt_sync;
                alt_disperr_reg1            <= alt_disperr;
                alt_ctrldetect_reg1         <= alt_ctrldetect;
                alt_errdetect_reg1          <= alt_errdetect;
                alt_rmfifodatadeleted_reg1  <= alt_rmfifodatadeleted;
                alt_rmfifodatainserted_reg1 <= alt_rmfifodatainserted;
                alt_patterndetect_reg1      <= alt_patterndetect;
                alt_runningdisp_reg1        <= alt_runningdisp;
            end
    
    end 
	
generate if ( DEVICE_FAMILY == "STRATIXIIGX" || DEVICE_FAMILY == "ARRIAGX" )
begin          
		always @ (posedge reset or posedge clk)
		begin
		 if (reset == 1'b1)
			begin
				altpcs_dataout              <= 8'h0;
				altpcs_disperr              <= 1'b1;
				altpcs_ctrldetect           <= 1'b0;
				altpcs_errdetect            <= 1'b1;
				altpcs_rmfifodatadeleted    <= 1'b0;
				altpcs_rmfifodatainserted   <= 1'b0;
			end
		 else
			begin
			   if (alt_sync == 1'b1 )
				 begin      
					altpcs_dataout              <= alt_dataout_reg1;
					altpcs_disperr              <= alt_disperr_reg1;
					altpcs_ctrldetect           <= alt_ctrldetect_reg1;
					altpcs_errdetect            <= alt_errdetect_reg1;
					altpcs_rmfifodatadeleted    <= alt_rmfifodatadeleted_reg1;
					altpcs_rmfifodatainserted   <= alt_rmfifodatainserted_reg1;
				 end
			   else
				 begin
					altpcs_dataout              <= 8'h0;
					altpcs_disperr              <= 1'b1;
					altpcs_ctrldetect           <= 1'b0;
					altpcs_errdetect            <= 1'b1;
					altpcs_rmfifodatadeleted    <= 1'b0;
					altpcs_rmfifodatainserted   <= 1'b0;
				 end
			end
		end
		assign altpcs_sync              = alt_sync_reg1;	      
end
else if ( DEVICE_FAMILY == "STRATIXIV" || DEVICE_FAMILY == "ARRIAIIGX" || DEVICE_FAMILY == "CYCLONEIVGX" || DEVICE_FAMILY == "HARDCOPYIV" || DEVICE_FAMILY == "ARRIAIIGZ"   || DEVICE_FAMILY == "STRATIXV" || DEVICE_FAMILY == "ARRIAV" || DEVICE_FAMILY == "ARRIAVGZ" || DEVICE_FAMILY == "CYCLONEV" || DEVICE_FAMILY == "ARRIA10" || DEVICE_FAMILY == "STRATIX10" || DEVICE_FAMILY == "CYCLONE10GX")
begin
	always @ (posedge reset or posedge clk)
    begin
     if (reset == 1'b1)
        begin
            altpcs_dataout              <= 8'h0;
            altpcs_disperr              <= 1'b1;
            altpcs_ctrldetect           <= 1'b0;
            altpcs_errdetect            <= 1'b1;
            altpcs_rmfifodatadeleted    <= 1'b0;
            altpcs_rmfifodatainserted   <= 1'b0;
			alt_sync_reg2               <= 1'b0;
        end
     else
        begin     
                altpcs_dataout              <= alt_dataout_reg1;
                altpcs_disperr              <= alt_disperr_reg1;
                altpcs_ctrldetect           <= alt_ctrldetect_reg1;
                altpcs_errdetect            <= alt_errdetect_reg1;
                altpcs_rmfifodatadeleted    <= alt_rmfifodatadeleted_reg1;
                altpcs_rmfifodatainserted   <= alt_rmfifodatainserted_reg1;
				alt_sync_reg2               <= alt_sync_reg1 ;
        end

    end
	

    assign altpcs_sync              = alt_sync_reg2;
end      
endgenerate




      
   //latched runlength violation assertion for "carrier_detect" signal generation block
   //reset the latch value after carrier_detect goes de-asserted
//   always @ (altpcs_carrierdetect or alt_runlengthviolation or alt_sync_reg1)
//    begin
//       if (altpcs_carrierdetect == 1'b0)
//        begin
//           alt_runlengthviolation_latched <= 1'b0;
//        end 
//       else
//        begin 
//           if (alt_runlengthviolation == 1'b1 & alt_sync_reg1 == 1'b1)
//            begin
//               alt_runlengthviolation_latched <= 1'b1;
//            end
//        end       
//    end

    always @ (posedge reset or posedge clk)
     begin
      if (reset == 1'b1)
         begin
             alt_runlengthviolation_latched <= 1'b0;
         end
      else
       begin
           if ((altpcs_carrierdetect == 1'b0) | (alt_sync == 1'b0))
            begin
               alt_runlengthviolation_latched <= 1'b0;
            end 
           else
            begin 
               if ((alt_runlengthviolation == 1'b1) & (alt_sync == 1'b1))
                begin
                   alt_runlengthviolation_latched <= 1'b1;
                end
            end       
       end
     end
	  
   // carrier_detect signal generation
   always @ (posedge reset or posedge clk)
    begin
     if (reset == 1'b1)
        begin
            altpcs_carrierdetect <= 1'b1;
        end
     else

        // This portion of code is to workaround the issue with PHYIP (hard PCS) for not implementing the carrier_detect, 
        // which suppose to be implemented based on 10b character, not 8b. 
        // 
        // The real challenge is to detect the /INVALID/ 10b code group
        //
        // This is the Table 36.3.2.1 in UNH test plan
        // =====================================================
        // RD-          code-group     RD+            code-group
        // =====================================================
        // 001111 1010  /K28.5/        110000 0101    /K28.5/
        // 001111 1011  /INVALID/      110000 0100    /INVALID/
        // 001111 1000  /K28.7/        110000 0111    /K28.7/
        // 001111 1110  /INVALID/      110000 0001    /INVALID/
        // 001111 0010  /K28.4/        110000 1101    /K28.4/
        // 001110 1010  /D28.5/        110001 0101    /D3.2/
        // 001101 1010  /D12.5/        110010 0101    /D19.2/
        // 001011 1010  /D20.5/        110100 0101    /D11.2/
        // 000111 1010  /D7.5/         111000 0101    /D7.2/
        // 011111 1010  /INVALID/      100000 0101    /INVALID/
        // 101111 1010  /INVALID/      010000 0101    /INVALID/

        begin
           if (  (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'h1C & alt_ctrldetect_reg1 == 1'b1 & alt_errdetect_reg1 == 1'b1  
                    & alt_disperr_reg1 ==1'b1 & alt_patterndetect_reg1 == 1'b1 & alt_runlengthviolation_latched == 1'b0                 ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'h1C & alt_ctrldetect_reg1 == 1'b1 & alt_errdetect_reg1 == 1'b1  
                    & alt_disperr_reg1 ==1'b1 & alt_patterndetect_reg1 == 1'b0 & alt_runlengthviolation_latched == 1'b0                 ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'hFC & alt_ctrldetect_reg1 == 1'b1 & alt_patterndetect_reg1 == 1'b1      ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'hFC & alt_ctrldetect_reg1 == 1'b1 & alt_patterndetect_reg1 == 1'b0      ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'h9C & alt_ctrldetect_reg1 == 1'b1 & alt_patterndetect_reg1 == 1'b0      ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'hBC & alt_ctrldetect_reg1 == 1'b0 & alt_patterndetect_reg1 == 1'b0      ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'hAC & alt_ctrldetect_reg1 == 1'b0 & alt_patterndetect_reg1 == 1'b0      ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'hB4 & alt_ctrldetect_reg1 == 1'b0 & alt_patterndetect_reg1 == 1'b0      ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'hA7 & alt_ctrldetect_reg1 == 1'b0 & alt_patterndetect_reg1 == 1'b0 
                    & alt_runningdisp_reg1 == 1'b1                                                                                      ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'hA1 & alt_ctrldetect_reg1 == 1'b0 & alt_patterndetect_reg1 == 1'b0 
                    & alt_runningdisp_reg1 == 1'b1 & alt_runlengthviolation_latched == 1'b1                                             ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'hA2 & alt_ctrldetect_reg1 == 1'b0 & alt_patterndetect_reg1 == 1'b0 
                   & alt_runningdisp_reg1 == 1'b1  
                   & ((alt_runningdisp == 1'b1 & alt_errdetect_reg1 == 1'b1 & alt_disperr_reg1 == 1'b1)|
                      (alt_runningdisp == 1'b0 & alt_errdetect_reg1 == 1'b1 & alt_disperr_reg1 == 1'b0)|
                      (alt_runningdisp == 1'b1 & alt_errdetect_reg1 == 1'b1 & alt_disperr_reg1 == 1'b0))                                ) |

                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'h43 & alt_ctrldetect_reg1 == 1'b0 & alt_patterndetect_reg1 == 1'b0      ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'h53 & alt_ctrldetect_reg1 == 1'b0 & alt_patterndetect_reg1 == 1'b0      ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'h4B & alt_ctrldetect_reg1 == 1'b0 & alt_patterndetect_reg1 == 1'b0      ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'h47 & alt_ctrldetect_reg1 == 1'b0 & alt_patterndetect_reg1 == 1'b0
                   & alt_runningdisp_reg1 == 1'b0                                                                                       ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'h41 & alt_ctrldetect_reg1 == 1'b0 & alt_patterndetect_reg1 == 1'b0
                   & alt_runningdisp_reg1 == 1'b0 & alt_runlengthviolation_latched == 1'b1 
                   & ((alt_runningdisp == 1'b1 & alt_errdetect_reg1 == 1'b1 & alt_disperr_reg1 == 1'b0)|                                                                                
                      (alt_runningdisp == 1'b0 & alt_errdetect_reg1 == 1'b1 & alt_disperr_reg1 == 1'b1 ))                               ) |
                 (alt_sync_reg1 == 1'b1 & alt_dataout_reg1 == 8'h42 & alt_ctrldetect_reg1 == 1'b0 & alt_patterndetect_reg1 == 1'b0
                   & alt_runningdisp_reg1 == 1'b0 & ((alt_runningdisp == 1'b1 & alt_errdetect_reg1 == 1'b1 & alt_disperr_reg1 == 1'b0)|
                                                     (alt_runningdisp == 1'b0 & alt_errdetect_reg1 == 1'b1 & alt_disperr_reg1 == 1'b1)) )  
              )

             begin      
                altpcs_carrierdetect              <= 1'b0;
             end
           else
             begin
                altpcs_carrierdetect              <= 1'b1;
             end
        end

    end




endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "HoVSOURGC04ioYPYbYhQ+dAr0NqzvVuBbBuoSNSTaodUtTXAGxV9RDZ3hsZ2j+YeKljE913jbrx7NO82a2X5u3nfkarDH1jEOokOrvdO5PSFY37K21Jeu5Nv2NlWvLYKPFtEZipaJwGMC7tg6DQ3BrVSBQ3nG97mEN7J1ajOWjzrEOMbmpVF0efl8YDEEBZ+Jby/TVrzFR0vMXREO48dD1w8MiIAfo8zURmTHK7imU8cKRUttPnbPCcA4MifiK2m7lag2UOHL8HPGteAd1q0R3kaA6g9/L8CJMwWm6+JRN42ZHth5C2fkCtrRoZOSCHjGbFHPLwoS3+ugLDzQsUoX10VPOyXDJaAGpPg0Z3ZEUZXDxnSfW1nnjHpKr/Kay8ESEsoXcx7mir/kUnG6gIgsSd7/ZmLnJDivNVJPDlrFWDMPXriZoB4WnUKCjsBodoA9vMx68DxcXk7NmT/ASRAwgO2LgIvh3skBDBLjCfUfSdwJU5W+sj2tJ4y/2KMrUgQGTlLcf48izFUDNq24+YHhhkG03wa7VisJnw9jVH7L1Uhj564pNkx4RNxB2vEbAILW40cxaDzrA6hy/rW/jwPCnpSJwtuQuDsJ+Iz9EN21UO2dg7fnksPlPBztdV/7/VrlwQCOnQuXHGg9Eih/FTDyRm/ObC0I92Acuhrua5n0YmQy2mIvM9zoDcVLDVyvseD6SYAzEDMy4G9VYTUYxw1mcr7QLfnTAJ1Sei3J1SydVDS2+kwkz6y90Q4sj6qZVi9IGLrKoyOkZ4HI1UE0MGxjnOVyMF3vuJLoR8Dt3yYkGtcz4fsGQGl9Otrw3onJmp1O0jhZKO64xBIInyln9lThaZFYkcLUznFo6qQy0T/IIrpA9hZqTOYbxXwDbbFdKZqjjwW2+g+7wlDgB4DrG7ep7sbzx3Mo40MlwDsd1nOhO+wMTsSvV/ZsO+GiTNfb/xfifkHQO7PJxlah17KKpcfqQTBz3OUf868JzIy5UXdgIq1G9ZFRXaNdc9mun9xu05f"
`endif