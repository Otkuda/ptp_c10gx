/*
 *============================
 * 7-segment display
 * 
 * btko - Aug'22
 *============================
 */

//=======================
//2x 7-segment display for StepFPGA
//=======================
module sevenSeg (
		input	wire disable1, disable2,
		input  wire [4:0] seg_data_1, seg_data_2,
		output wire [8:0] segment_led_1, segment_led_2
	);
	
	a_segment s0 ( .dis(disable1), .data(seg_data_1),  .segment_led(segment_led_1) );
	a_segment s1 ( .dis(disable2), .data(seg_data_2),  .segment_led(segment_led_2) );
endmodule


//==============================
//	__ a single segment __
//	
//	input
//		dis = 1: blank display
//		data[4] = decimal point
//		data[3:0] = 0 ~ F
//	output
//		segment_led connects to 7-segment display
//==============================
module a_segment (
		input wire dis,
		input wire [4:0] data,
		output wire [8:0] segment_led
	);
	
	reg [6:0] seg [15:0];
	initial begin
		seg[0] = 7'h3f;   //  0
		seg[1] = 7'h06;   //  1
		seg[2] = 7'h5b;   //  2
		seg[3] = 7'h4f;   //  3
		seg[4] = 7'h66;   //  4
		seg[5] = 7'h6d;   //  5
		seg[6] = 7'h7d;   //  6
		seg[7] = 7'h07;   //  7
		seg[8] = 7'h7f;   //  8
		seg[9] = 7'h6f;   //  9
		seg[10]= 7'h77;   //  A
		seg[11]= 7'h7C;   //  b
		seg[12]= 7'h39;   //  C
		seg[13]= 7'h5e;   //  d
		seg[14]= 7'h79;   //  E
		seg[15]= 7'h71;   //  F
	end
	assign segment_led = dis ? 8'h0 : {data[4], seg[data[3:0]]};
endmodule
