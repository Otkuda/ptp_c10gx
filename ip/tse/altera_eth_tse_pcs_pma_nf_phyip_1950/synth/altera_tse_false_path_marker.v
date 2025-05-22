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
// 
// -----------------------------------------------
// False path marker module
// This module creates a level of flops for the 
// targetted clock, and cut the timing path to the
// flops using embedded SDC constraint
//
// Only use this module to clock cross the path
// that is being clock crossed properly by correct
// concept.
// -----------------------------------------------
`timescale 1ns / 1ns

module altera_tse_false_path_marker 
#(
   parameter MARKER_WIDTH = 1
)
(
   input    reset,
   input    clk,
   input    [MARKER_WIDTH - 1 : 0] data_in,
   output   [MARKER_WIDTH - 1 : 0] data_out
);

(*preserve*) reg [MARKER_WIDTH - 1 : 0] data_out_reg;


assign data_out = data_out_reg;

always @(posedge clk or posedge reset) 
begin
   if (reset)
   begin
      data_out_reg <= {MARKER_WIDTH{1'b0}};
   end
   else
   begin
      data_out_reg <= data_in;
   end
end

endmodule
`ifdef QUESTA_INTEL_OEM
`pragma questa_oem_00 "mKhIJBmj3DrsnDN4thRWhdUc6jt93zjYGXJ10zD3tAdiXcOV17sX2sDsy15q4IewG5zPtIQ6l/C48sneMszAWz/EH+yebnm9R9cbIUsCz3rqvoeatk7lHwHnwHg1ziDDm0XOe6dydIuDL7vH/75CWsHZF8Eke9nDQQvFPnaiDIcD5V/lsenxQa1po30SZF93fwHGt1oIgL+czVwbVaH54WhnwmhnhjCdaqg5mGnq3qs/sKqeU2nDB7jVUsFGU3ShIzotk5NgZiTzLB1RC6fxWFjXE1cfNrjnTKy6ZmtWQ8P8FwznRMx+BDb7Qff/EUlRMe4ZWk9ql9cMWYJ9HXFhHaebhx+afQ6uLauUZt8BDt4ce1plBx0lMElVnn5q+54OorKM6wBV4siqDiCd2ugCN8yEbqD32Tq5M4fdu55ZF0wV4OJ8Gnj0ORl7q7+ohLViFDAlgjhYYHv84BrzzopqvnW2vW62GkganjWpZWWf1+yFhx8FGFk8jzTAV09eYXaiyFxlrUA/me34lO19Xwbe+UXjKf6o/0Zorw4x7U8rlvgMXO75FBYPRUYEtZXUuJnxC5pFDmJJHi/pJW0nQ5nbhcbrQi4NA5wHsqc3vbBlIIQbgNiUDH9sOT2IaH+g7HmgrPesK7KGvc/8ptZh9Sx+e7HqgEALWWaNJQYlKEJx5enS+OfH241JqU7fV6AB48lygv+bUlWayLM5YOHnRb5Khj3RmnJKagK1XpSw59N3RcIzIaq2U3hulD4vseNGrMb19Zchl26GXnkz3LqwOgvvYQ9xOITW77II/Vau9J/uQDynqaQp5cdyyob1NTDL8sIEfXRU7mfgi6IO8RMSSOWmedSE7wMep2R83nIqI6CiMp8hVqPai8LoTapRtUw0KAeOYi6woEIvC78wPbidm9CRT+XBnQlHdsP4UtdPUEUC6CEyksEKpO7nPdQ6NeoPWDB1KxLTDkNVNuudpzAqcPOcgs0ixNp51U7XYrrKh9rxV/sUM/xh4fdFA1IZSkrteWSw"
`endif