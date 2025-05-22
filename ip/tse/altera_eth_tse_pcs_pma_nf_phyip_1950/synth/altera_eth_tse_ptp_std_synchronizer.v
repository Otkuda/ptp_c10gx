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


`timescale 1ns / 1ns

module altera_eth_tse_ptp_std_synchronizer #(
    parameter width = 1,
    parameter depth = 3
) (
    input   clk,
    input   reset_n,
    input   [width-1:0] din,
    output  [width-1:0] dout
);

genvar i;
generate
for (i = 0; i < width; i = i + 1) begin: nocut_sync    
    altera_std_synchronizer_nocut #(
        .depth(depth)
    ) std_sync_nocut (
        .clk        (clk),
        .reset_n    (reset_n),
        .din        (din[i]),
        .dout       (dout[i])
    );
end    
endgenerate
    
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "mKhIJBmj3DrsnDN4thRWhdUc6jt93zjYGXJ10zD3tAdiXcOV17sX2sDsy15q4IewG5zPtIQ6l/C48sneMszAWz/EH+yebnm9R9cbIUsCz3rqvoeatk7lHwHnwHg1ziDDm0XOe6dydIuDL7vH/75CWsHZF8Eke9nDQQvFPnaiDIcD5V/lsenxQa1po30SZF93fwHGt1oIgL+czVwbVaH54WhnwmhnhjCdaqg5mGnq3qsf3WzPLHZfKzzspE1rN8i2KoUDd5pTUmJLgl31W+itqZVwy5J9OiRrg5JBlbzAKMaAhVSkk/JqoyPUoiZTMUwRB4CDB+udknHqdJLvV5Kf6YzFJLml6yWBa+M6ZZGxe6B9imje38fICM6mQTOQuuvS1ha+t2VxmO7LY/CcroD9t12SID5O6c65qH7Dm/zoUN6w9b4YEyccgWNdOrvWvhrDSlRb3Cen5fbGf4QC7DCSKhwyNrlK6ePM2tdo239Me+/PdPEAcBlpC1U0+XdznPz2xoFCoocJ0VmL1rwEOJ4E+jKm601CpDY1gb3zfWTYDx5Z2E9JgTqL+cJ0Ir/OUBBc76MRmRoI596pCGR79VHXq5J+Gy/lDPwO0kxFO9XOtjyDJNbnFnwsySuoOAjKuE1R61MK2NGUFq1g1tdU2k/nsf68Zw0epUvlvbGqaCIpDZEVbvTx1bzhAMbmJ0+DliBiJKa+wlIi0j7C0T+nPwoT4D+MgWoFC9W1soXiohtXdA7lwZTUO9+4TzlG1G7iK2WG8a/OHQ8Uk/vv9LWfYaZCM/OWjiAMHGtTspv0OFbyIOgvqAQ1Ygo5g3+7pu3WOEOj0xWpItMUiW+H+1BPN/4bwedyyT19Aw/Pqcs3GH5YregzNUGrCvxrKFwejyylqBb3PPDEHFodKUvJ9qTkXKTLSiqkCplixor5is2EehyhsGb3Px2aSOIyXcUe3UpwHvKDuHGp2X2S2M8zrX3cHl82mJyerk1ZVpugGmAe1i18iZPVrkdV3mYbXfV9UgFW4Cgn"
`endif