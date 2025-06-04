	myRAM u0 (
		.data    (_connected_to_data_),    //   input,  width = 32,    data.datain
		.q       (_connected_to_q_),       //  output,  width = 32,       q.dataout
		.address (_connected_to_address_), //   input,   width = 9, address.address
		.wren    (_connected_to_wren_),    //   input,   width = 1,    wren.wren
		.clock   (_connected_to_clock_),   //   input,   width = 1,   clock.clk
		.byteena (_connected_to_byteena_)  //   input,   width = 4, byteena.byte_enable
	);

