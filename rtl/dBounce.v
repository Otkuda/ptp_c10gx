/*
 *============================
 * debounce
 * 
 * btko - Aug'22
 *============================
 */
 
 // xBitDebounce: create dBounce bus of width NUMBITS
 module xBitDebounce #(
	parameter NUMBITS = 3
 ) (
	input wire clock,
	input wire [NUMBITS-1:0] i_db,
	output wire [NUMBITS-1:0] o_db
);
	
	
	genvar i;
	generate
		for (i=0; i<NUMBITS; i=i+1) begin : HiThere
			dBounce #(.NUMCYCLES (500_000)) dbgen (
				.i_clk (clock),
				.i_db  (i_db[i]),
				.o_db  (o_db[i])
			);
		end
	endgenerate
endmodule




/*
 * debounce 
 *
 * low pass filter i_db need to be stable for a certain *delay* before o_db follows.
 * 	*delay* = i_clk frequency / NUMCYCLES
 *		DEFAULT_STATE = starting, idle polarity
 *
	algo
	eg for NUMCYCLES = 2: 
		NUMBITS = 2
		MAX_COUNT = 110b
		MIN_COUNT = 010b

		111                                    ____  count[MSB] = output
		110		<= max_count                  /       1
		101                                  /        1    ^ output 1
		100		<= starting point           /         1 ___|__
		011                                /          0          } output 0
		010		<- min_count           ___/           0          }
		001
		000

 * btko - Jul 2022
 */
module dBounce (
		input i_clk, i_db,
		output o_db
	);
	parameter NUMCYCLES = 50_000;		// how many cycles at least >=1, cannot be 0
	parameter DEFAULT_STATE = 1'b1;	// default pin state
	
	localparam NUMBITS = $clog2(NUMCYCLES)+1;		// number of bits+1 to count NUMCYCLES 
	localparam MAX_COUNT = {1'b1,{NUMBITS{1'b0}}} + NUMCYCLES;	
	localparam MIN_COUNT = {1'b1,{NUMBITS{1'b0}}} - (NUMCYCLES);

	reg [NUMBITS:0] count = { NUMBITS{DEFAULT_STATE} };		// counter, init default based on DEFAULT_STATE
	
	// increment count if input value = 1 and hasn't reached max
	// decrement count if input value = 0 and hasn't reached min, 
	// otherwise, stay put
	always @(posedge i_clk) 
		count <= (count != MAX_COUNT && i_db) ? count+1 :
				(count != MIN_COUNT && !i_db) ? count-1 :
				count;
				
	// count MSB is the output, see ascii diag above
	assign o_db = count[NUMBITS] ? 1 : 0;
endmodule


