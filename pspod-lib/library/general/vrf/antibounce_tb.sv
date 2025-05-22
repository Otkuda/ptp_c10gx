`timescale 1ns/10ps

    //
    // Antibounce test
    //

module antibounce_tb ();

logic clk125mhz, rst_n;

// global reset
initial begin
	rst_n = '1;
	#4 rst_n = '0;
	#4 rst_n = '1;
end

// basic clock rate 
initial begin
	clk125mhz = '0;
	forever #4 clk125mhz = ~clk125mhz;
end

// bounce generator
logic bounce;

initial begin
	bounce = '0;
end

always begin
    // bounce up
    #50000 bounce = ~bounce;
    #50000 bounce = ~bounce;
    #100000 bounce = ~bounce;
    #100000 bounce = ~bounce;
    #1500000 bounce = ~bounce;
end

// DUT
logic clear_sig;

antibounce #(.DELAY(1),.FREQ(125)) dut (
        .clk ( clk125mhz ),
        .rst_n ( rst_n ),

        .i_sig (bounce),
        .o_sig (clear_sig)
    );

// observe the results in a waveform

endmodule : antibounce_tb
