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


// Clocked priority encoder with state
//
// On each clock cycle, updates state to show which request is granted.
// Most recent grant holder is always the highest priority.
// If current grant holder is not making a request, while others are, 
// then new grant holder is always the requester with lowest bit number.
// If no requests, current grant holder retains grant state

// $Header$

`timescale 1 ns / 1 ns
//altera message_off 16753
module alt_xcvr_arbiter #(
	parameter width = 2
) (
	input  wire clock,
	input  wire [width-1:0] req,	// req[n] requests for this cycle
	output reg  [width-1:0] grant	// grant[n] means requester n is grantee in this cycle
);

	wire idle;	// idle when no requests
	wire [width-1:0] keep;	// keep[n] means requester n is requesting, and already has the grant
							// Note: current grantee is always highest priority for next grant
	wire [width-1:0] take;	// take[n] means requester n is requesting, and there are no higher-priority requests

	assign keep = req & grant;	// current grantee is always highest priority for next grant
	assign idle = ~| req;		// idle when no requests

	initial begin
		grant = 0;
	end

	// grant next state depends on current grant and take priority
	always @(posedge clock) begin
		grant <= 
// synthesis translate_off
                    (grant === {width{1'bx}})? {width{1'b0}} :
// synthesis translate_on
				keep				// if current grantee is requesting, gets to keep grant
				 | ({width{idle}} & grant)	// if no requests, grant state remains unchanged
				 | take;			// take applies only if current grantee is not requesting
	end

	// 'take' bus encodes priority.  Request with lowest bit number wins when current grantee not requesting
	assign take[0] = req[0]
					 & (~| (keep & ({width{1'b1}} << 1)));	// no 'keep' from lower-priority inputs
	genvar i;
	generate
	for (i=1; i < width; i = i + 1) begin : arb
		assign take[i] = req[i]
						 & (~| (keep & ({width{1'b1}} << (i+1))))	// no 'keep' from lower-priority inputs
						 & (~| (req & {i{1'b1}}));	// no 'req' from higher-priority inputs
	end
	endgenerate
endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "5GxlsB988ZPhX+n6/uQKQK9sWwu84ase2EeQste6n76wUdtYN1nAigJri22qsP8C4GVDoEgW2+uexgs6Gtc5RDo3FQwYkagKp349zwSStorGaychB7toL0szbIjvmW+Wxt+OOgJ501L24bgjo8McPjUXEh0j1awpvwfX336YgXodS9KZjtPRREbwuDx/dvZEKrSjtejGb/5EMLAyRj50/fY77d/yx04OsXRLA3Cft+iwgA5n7Q+LBgq9Pp1tw022jdo+gj6M1iX9r+HNkCVfwtJJ13xpYVE0oJ0UVmut08sVKgWffJkNHzAeQML5gVnPc81DNmKsJZMFX2uFueIqCPwOu7CnE6CTeifD1xfDG0aBHbnlN4xQtKihyK+f22obzDrvMen+SSVnm2QpfBDXCh+XL7PQS134tRiacYhLZNqR+tcc2+7y+meU2KUTfziL/5GvJH7HIhC/ACAwEn63QAFKx1Q7gzKGY6bk4iF3fgtcygXeYO0cwKANl78JPiOLCIdvDug87zTNxV/TCOnqNuXsIWHFKc8I41VCiryHHq+eyr7L5Mc7/hMJMvnBs6no8iO4p6AAeAV5RQMVPvCCzdyphWkhSOBpUNgRnvyXgY59H/vT3X5XmSSMy0GW8nB60oZXxk0ftvGsgUrZEQ+Of2q58tXVVC/vi0TRORK2ZhWGqw/Q3kfW5tmH7DgwlaQFDgeEEaKs/iGBNItGl5LZ0u2JLFgdwhKkpmYZZC6BnjHaQWojp9KDjhG9KJZZiUOrcPoq4J0S3yHZWtsyXRpT58n7f5JK+g+1OPQRbWOJr+JOCJg5+7+1MCAmJsmZF6amEYdEKjsDpiaEcP4aBUbd65uTF0pyyxwW6IkRMKrIhCNRWfxYZyS9EOGf4N6Dr+6vFUZRnN5zPfZlJP13zoSD7Ix2fc/DXMAk+xGwVcgVhGmub1S1xK1jjzzz2FrpVBRsu9mXxowaYpgDiRR3XITlUqVuGZKuoK6JR0I/kj1iH4CGcuuRfj6W03OcPmJxrtfX"
`endif