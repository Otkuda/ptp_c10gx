module myROM (
		output wire [31:0] q,       //       q.dataout, Data output of the memory.The q port is required if the operation_mode parameter is set to any of the following values:SINGLE_PORT,DUAL_PORT,BIDIR_DUAL_PORT,QUAD_PORT
		input  wire [9:0]  address, // address.address, Adress input of the memory.The address signal is required for all operation modes.
		input  wire        clock    //   clock.clk,     Memory clock, refer to user guide for specific details
	);
endmodule

