module wb_interconnect
#( 
	parameter NUM_SLAVE = 3    
 )  
(
	input clk, 
    input rst,
	
	// Wishbone signals Master
	input i_wbm_cyc,
	input i_wbm_stb,
	input i_wbm_we,
    input [31:0] i_wbm_addr,
	input [31:0] i_wbm_data,
    output [31:0] o_wbm_data, //vot
	output reg o_wbm_ack,
	
	// Wishbone signals Slaves
	output [NUM_SLAVE-1 : 0] o_wbs_cyc,
	output [NUM_SLAVE-1 : 0] o_wbs_stb,
	output [NUM_SLAVE-1 : 0] o_wbs_we,
    output [31:0] o_wbs_addr,
	output [31:0] o_wbs_data,
    input [(32*NUM_SLAVE)-1 : 0] i_wbs_data,
	input reg [NUM_SLAVE-1 : 0] i_wbs_ack
	
);

 
assign o_wbs_cyc = i_wbm_cyc << (i_wbm_addr[15:8]);
assign o_wbs_stb = i_wbm_stb << (i_wbm_addr[15:8]);
assign o_wbs_we = i_wbm_we << (i_wbm_addr[15:8]);
assign o_wbs_data = i_wbm_data;
assign o_wbs_addr = i_wbm_addr;

assign o_wbm_ack = i_wbs_ack[(i_wbm_addr[15:8])];


assign o_wbm_data = i_wbs_data [(32 *( i_wbm_addr[15:8]+1))-1 -: 32];


endmodule
