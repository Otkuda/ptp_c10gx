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


//
// Module Name : altera_eth_tse_std_synchronizer_bundle
//
// Description : Bundle of bit synchronizers. 
//               WARNING: only use this to synchronize a bundle of 
//               *independent* single bit signals or a Gray encoded 
//               bus of signals. Also remember that pulses entering 
//               the synchronizer will be swallowed upon a metastable
//               condition if the pulse width is shorter than twice
//               the synchronizing clock period.
//

`timescale 1 ps / 1 ps
module altera_eth_tse_std_synchronizer_bundle  (
                                        clk,
                                        reset_n,
                                        din,
                                        dout
                                        );
    // GLOBAL PARAMETER DECLARATION
    parameter width = 1;
    parameter depth = 3;   
   
    // INPUT PORT DECLARATION
    input clk;
    input reset_n;
    input [width-1:0] din;

    // OUTPUT PORT DECLARATION
    output [width-1:0] dout;
   
    generate
        genvar i;
        for (i=0; i<width; i=i+1)
        begin : sync
            altera_eth_tse_std_synchronizer #(.depth(depth))
                                    u  (
                                        .clk(clk), 
                                        .reset_n(reset_n), 
                                        .din(din[i]), 
                                        .dout(dout[i])
                                        );
        end
    endgenerate
   
endmodule // altera_eth_tse_std_synchronizer_bundle
// END OF MODULE
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "mKhIJBmj3DrsnDN4thRWhdUc6jt93zjYGXJ10zD3tAdiXcOV17sX2sDsy15q4IewG5zPtIQ6l/C48sneMszAWz/EH+yebnm9R9cbIUsCz3rqvoeatk7lHwHnwHg1ziDDm0XOe6dydIuDL7vH/75CWsHZF8Eke9nDQQvFPnaiDIcD5V/lsenxQa1po30SZF93fwHGt1oIgL+czVwbVaH54WhnwmhnhjCdaqg5mGnq3qsmJzaoR+43cf+y/GSdCPvmvhZ7CNtizJO+Au2+9MSrAGmRymbE6W3ERrCEvXoFfs4o5z1afIE5qNM3nKa3mcffh6usFxbx37HGXTsuB4OfDbdF648tF4EsqNQMDKaDr8p/ewgIx74m8pON0neKtNaRXt8d9ypdJQkxSdHRxfWTLP94KIH2AcJH6WER4YbrCNljrVlXPWK0febhTDyXpE/m5pO4nDRTzqfFsaRjC7BdtWtHfWc8KDt82E8qknaz1SZzW6aGi3A1S79Jr93DVnNM4fdWMIvy6qnJaqqaJOho9waxY84+zBVepht9gIF/KejvCQaTRweOVQ9SuPvPb6XS1a51c4HYrXB7d5O9hHfv9xVcEqbMI/v3IsbMaLNSGJelE2mXhPL4WXf6A/L2jhDilsiEdYfzojRT8pGe/MKsNVk0Q1c651vJVeuPrMfzfLRQl5iTi330u6ekFblI1TnmbDr0YXs18vWtyI3GkkUMXzs4SY9+FGSxOexC/6tBozvaDGJ7z4hhublJS6NilslL+ioSbO6htWl/ZOpEQFEMOaGdK4CshJyfPnBBf5kQhnyjt6oxIxGOtMkVEUU0hpsSmE76i7gNP/7XI+NFiQPD9f0eVgtZWEsmYPbw+Z0G8vMBqzoVHYRPfCeeP+HkceoLVEmxT5NjCdle8Jc2Icf2q7KBZ0+ZD4vg7KzPPwapxSSx0YhCj09JwLb6II1CeKkE5PGyKRk7ZvkRdX8+s/0H2fobclaSBowfDcRFI/gF1/Y2FD++orcINx7Q4pzNEILb"
`endif