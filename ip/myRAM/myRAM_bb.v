module myRAM (
		input  wire [31:0] data,    //    data.datain,      Data input of the memory.The data port is required for all RAM operation modes:SINGLE_PORT,DUAL_PORT,BIDIR_DUAL_PORT,QUAD_PORT
		output wire [31:0] q,       //       q.dataout,     Data output from the memory
		input  wire [7:0]  address, // address.address,     Address input of the memory
		input  wire        wren,    //    wren.wren,        Write enable input for address port. The wren signal is required for all RAM operation modes:SINGLE_PORT,DUAL_PORT,BIDIR_DUAL_PORT,QUAD_PORT
		input  wire        clock,   //   clock.clk,         Memory clock,refer to user guide for specific details
		input  wire [3:0]  byteena  // byteena.byte_enable, Byte enable input to mask the data port so that only specific bytes, nibbles, or bits of data are written. It is supported in Intel Agilex devices when you set the ram_block_type parameter to MLAB.
	);
endmodule

