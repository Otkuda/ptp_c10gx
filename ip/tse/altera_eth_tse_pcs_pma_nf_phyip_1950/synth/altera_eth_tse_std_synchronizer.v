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



// START_FILE_HEADER ----------------------------------------------------------
//
// Filename    : altera_eth_tse_std_synchronizer.v
//
// Description : Contains the simulation model for the altera_eth_tse_std_synchronizer
//
// Owner       : Paul Scheidt
//
// Copyright (C) Altera Corporation 2008, All Rights Reserved
//
// END_FILE_HEADER ------------------------------------------------------------

// START_MODULE_NAME-----------------------------------------------------------
//
// Module Name : altera_eth_tse_std_synchronizer
//
// Description : Single bit clock domain crossing synchronizer. 
//               Composed of two or more flip flops connected in series.
//               Random metastable condition is simulated when the 
//               __ALTERA_STD__METASTABLE_SIM macro is defined.
//               Use +define+__ALTERA_STD__METASTABLE_SIM argument 
//               on the Verilog simulator compiler command line to 
//               enable this mode. In addition, dfine the macro
//               __ALTERA_STD__METASTABLE_SIM_VERBOSE to get console output 
//               with every metastable event generated in the synchronizer.
//
// Copyright (C) Altera Corporation 2009, All Rights Reserved
// END_MODULE_NAME-------------------------------------------------------------

`timescale 1ns / 1ns

module altera_eth_tse_std_synchronizer  #(
    parameter depth = 3
) (
    input   clk,
    input   reset_n,
    input   din,
    output  dout
);
    
    altera_std_synchronizer_nocut #(
        .depth(depth)
    ) std_sync_no_cut (
        .clk        (clk),
        .reset_n    (reset_n),
        .din        (din),
        .dout       (dout)
    );
    
endmodule
      
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "mKhIJBmj3DrsnDN4thRWhdUc6jt93zjYGXJ10zD3tAdiXcOV17sX2sDsy15q4IewG5zPtIQ6l/C48sneMszAWz/EH+yebnm9R9cbIUsCz3rqvoeatk7lHwHnwHg1ziDDm0XOe6dydIuDL7vH/75CWsHZF8Eke9nDQQvFPnaiDIcD5V/lsenxQa1po30SZF93fwHGt1oIgL+czVwbVaH54WhnwmhnhjCdaqg5mGnq3qtW5qE7HQEiXzhdTnf2vJEKRX+6oaiC7LPEHEeJMWB6YZ4GvOislCjOF6Jf7naCqwlIQenkstRoffCi1QWX9KUeJm8YtM6XBnREegJX7V5TilF9qucZVaDNbQa+mcLhP3ck8KyPeGbFhiDJ6Na2bnAIDAlzIHzZNXblwYnuuUy1fwdVGzQ7GfKDoUyNjMLwRSdk05+H0XEdwHxEcQ8CanEocrMuFCm5hSxCSyxSf9K3AEoDhMURMLFUI/H0eCNaxdmyZ6jRG4HHhcsQWImPgAvjFndi5Fs0KoNWMuHXjyOy4cyblvHfZangrvn13siUSllFhBAK2MksR0QoBQYO4726iCau6tQRq2SKVvkqxlfufO8CHGDx/GaGOQBaEv4ylzZEMpGm2zxLSJjacWqj8fjvwf4GTjqYDHgCzpTTy2njAFQqLfcvLFrxoOP7JuvRPz3ZB6EGKs4OGLAJ8G5qSILHAcaoIgs0wPEacAhdkR/YJeyykRRzcPeHVCovZ52I0tJqJf2GQvHHwVGcEmzWWKPxxup2drYRp58UyavCf9wvqa8+e67X/skRuE5MCdLi1aiNaw61Q732dxzFsQ5iSSqsu5xSkyh7qXYsQuljYQwwpiZwJvTGhoHYFZI22fMsgdaTvj5ZKxqNtfvAO4IuTCWI+q30d4p9KGCbTGqjrIrPKNoLZ0Mka28mc64Dcydr8Dh7DuQA/Nk2gkEnL2d9BZw2FsOHy0hqtcahjv0qtAEFqmgmbjpb0oOikQIVNLIpnNLd2OqRjeGgxpyfe3WmP1xe"
`endif