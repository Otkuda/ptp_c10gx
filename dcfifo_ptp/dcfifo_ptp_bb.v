module dcfifo_ptp (
		input  wire [127:0] data,    //  fifo_input.datain,  Data input of the memory.The data port is required for all FIFO operation.
		input  wire         wrreq,   //            .wrreq,   wrreq input signal to request for write operation.The wrreq signal is required for all FIFO operation.
		input  wire         rdreq,   //            .rdreq,   rdreq input signal to request for read operation.The rdreq signal is required for all FIFO operation.
		input  wire         wrclk,   //            .wrclk,   Positive-edge-triggered clock.
		input  wire         rdclk,   //            .rdclk,   Positive-edge-triggered clock.
		input  wire         aclr,    //            .aclr,    It is asynchronous reset.Assert this signal to clear all the output status ports, but the effect on the q output may vary for different FIFO configurations.
		output wire [127:0] q,       // fifo_output.dataout, Data output of the memory. This port is required for all FIFO operation.
		output wire [3:0]   rdusedw, //            .rdusedw, Show the number of words available for reading in the FIFO.
		output wire [3:0]   wrusedw, //            .wrusedw, Show the number of words written into the FIFO.
		output wire         rdempty, //            .rdempty, When rddmpty signal is asserted, the FIFO IP core is considered empty. You must always refer to the rdempty port to ensure whether or not a valid read request operation can be performed,regardless of the target device.
		output wire         wrfull   //            .wrfull,  when wrfull signal is asserted, the FIFO IP core is considered full.You must always refer to the wrfull port to ensure whether or not a valid write request operation can be performed,regardless of the target device.
	);
endmodule

