/*
 * Button [2:0] = button IRQ
 * Button 3 = async reset
 * TXD/RXD N,8,1 115200 connected to external CP2102
 * enabled interrupt for Buttons
 * Switches: direct connect
 *
 * -- btko Jul-22
 */


module soc (
		input 		 clock_main,	// 12MHz
		input 		 rst_n,
		input  [1:0] BUTTONn,
		output [3:0] LEDSn,
		output [2:0] RGB1n, RGB2n,
		output [8:0] SEG1n, SEG2n,
		input  [3:0] SW,
		output 		 TXD,
		input 		 RXD,

		output reg [31:0] wbm_adr_o,
		output reg [31:0] wbm_dat_o,
		input  		 [31:0] wbm_dat_i,
		output reg  			wbm_we_o,
		output reg [3:0]  wbm_sel_o,
		output reg 				wbm_stb_o,
		input 						wbm_ack_i,
		output reg 				wbm_cyc_o
	);

	
	// ~~~~~~~~~~  memory map ~~~~~~~~~~~~~~~~	sync with sections.lds, update sp in start.s
	localparam ROM_ADDR		=	32'h0000_0000;
	localparam ROM_ADDR_END	=	32'h0000_1FFF;
	localparam RAM_ADDR		=	32'h0000_2000;
	localparam RAM_ADDR_END	=	32'h0000_27ff;

	localparam LEDS_ADDR		= 32'h0200_0000;
	localparam SEG1_ADDR		= 32'h0200_2000;
	localparam SEG2_ADDR		= 32'h0200_2004;
	localparam RGB1_ADDR		= 32'h0200_3000;
	localparam RGB2_ADDR		= 32'h0200_3004;
	localparam UART_DAT_ADDR 	= 32'h0200_4000;		// for both R & W
	localparam UART_DIV_ADDR 	= 32'h0200_4008;
	localparam BUTTON_ADDR		= 32'h0200_5000;
	localparam SWITCH_ADDR		= 32'h0200_8000;

	localparam WB_BASE_ADDR = 32'h0300_0000;
	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	
	
	localparam RESET_ADDR	=	ROM_ADDR;
	localparam IRQ_ADDR		=	32'h0000_0008;		// irq table.. in start.s
	localparam STACK_ADDR	=	RAM_ADDR_END+1;

	// ========================= PLL =========================
	
	
	// ========================= CPU =========================
	(* keep *) wire mem_valid, mem_ready, mem_instr;
	wire [31:0] mem_addr;
	wire [31:0] mem_wdata;
	wire [3:0]  mem_wstrb;
	wire [31:0] mem_rdata;
	reg rom_ready;
	wire trapsig;
	reg [31:0] irq;
	wire [31:0] eoi;
	


	picorv32 #(
		.ENABLE_COUNTERS	(1),
		.BARREL_SHIFTER	(1),
		.ENABLE_IRQ			(1),
		.ENABLE_IRQ_TIMER	(1),
		.PROGADDR_RESET	(RESET_ADDR),
		.PROGADDR_IRQ		(IRQ_ADDR),
		.STACKADDR			(STACK_ADDR),
		.ENABLE_DIV(1),
		.ENABLE_MUL(1)
	) cpu (
		.clk		(clock_main),
		.resetn	(rst_n),
		.trap		(trapsig),
		.irq		(),		// input [31:0] irq
		.eoi		(eoi),		// output [31:0] eoi

		.mem_valid	(mem_valid),	//		output reg        mem_valid,	-- MEMORY ADDRESS VALID
		.mem_instr	(mem_instr),
		.mem_ready	(mem_ready),	//		input             mem_ready,
		.mem_addr	(mem_addr),		//		output reg [31:0] mem_addr,
		.mem_wdata	(mem_wdata),	//		output reg [31:0] mem_wdata,
		.mem_wstrb	(mem_wstrb),	//		output reg [ 3:0] mem_wstrb,
		.mem_rdata	(mem_rdata)		//		input      [31:0] mem_rdata
	);


	// ========================= ROM =========================
	// start addr 	: [0000_0000]
	// end_addr		: [0000_1FFF]
	wire [31:0] romout;
	myROM rom (
		.address	(mem_addr[12:2]),	// 1024 words x 32 bits
		.clock	(clock_main),
		.q			(romout)
	);
//	altsyncram #(
//		.operation_mode	("SINGLE_PORT"),
//		.width_a				(32),
//		.widthad_a			($clog2(1024)),
//		.init_file			("./fw/main.mif")
//	) rom (
//		.clock0		(clock_main),
//		.address_a	(mem_addr[11:2]),
//		.q_a			(romout)
//	);
	
	
	always @(posedge clock_main) 
		rom_ready <= mem_valid && !mem_ready && (mem_addr >= ROM_ADDR) && (mem_addr <= ROM_ADDR_END);

		
	// ========================= RAM =========================
	// start addr 	: [0000_2000]
	// end_addr		: [0000_23FF]
	reg ram_ready;
	reg ram_wren;
	wire [31:0] ram_out;

	myRAM ram (					// to debug with in-system memory content editor
		.address	(mem_addr[10:2]),
		.byteena (mem_wstrb),
		.clock	(clock_main),
		.data		(mem_wdata),
		.wren		(ram_wren),
		.q			(ram_out)
	);
	
	always @(posedge clock_main) begin
		ram_ready <= mem_valid && !mem_ready && (mem_addr >= RAM_ADDR) && (mem_addr <= RAM_ADDR_END);
		ram_wren <= (mem_valid && !mem_ready &&  (mem_addr >= RAM_ADDR) && (mem_addr <= RAM_ADDR_END) && |mem_wstrb);
	end


	// ========================= UART =========================
	// DATA addr 	: [0200_4000]
	// DIV addr		: [0200_4008]

	// divisor register
	wire uart_div_ready = mem_valid && mem_addr == UART_DIV_ADDR;
	wire [31:0] uart_div_reg_do;
	
	// data write register
	wire uart_dat_wait;
	wire uart_data_ready = mem_valid && (mem_addr == UART_DAT_ADDR);
	
	// data read register
	wire [31:0] uart_dat_do;
	

	simpleuart uart (
		.clk				( clock_main	),
		.resetn			( rst_n	),
		.ser_tx			( TXD		),
		.ser_rx			( RXD		),

		// r/w UART divisor register
		.reg_div_we		( uart_div_ready ? mem_wstrb : 4'h0),
		.reg_div_di		( mem_wdata	),
		.reg_div_do		( uart_div_reg_do	),

		// r/w UART data register
		.reg_dat_we		( uart_data_ready ? mem_wstrb[0] : 1'b0),
		.reg_dat_di		( mem_wdata			),
		.reg_dat_wait	( uart_dat_wait	),
		
		.reg_dat_re		( uart_data_ready && !mem_wstrb ),
		.reg_dat_do		( uart_dat_do		)
	);
	
	


	
	// ========================= Button (IRQ) x3, other button is 'reset' ==========
	// addr1 	: [0200_5000]
	(* keep *) wire [2:0] dBUTTONn;

	xBitDebounce #(.NUMBITS (2)) db3 (
		.clock	(clock_main),
		.i_db		(BUTTONn[1:0]),
		.o_db		(dBUTTONn)
	);

//	reg [31:0] button_reg;
	reg [1:0] button_reg;
	reg button_ready;
	always @(posedge clock_main)
		button_ready = mem_valid && !mem_ready && (mem_addr == BUTTON_ADDR);

	wire NandButton = ~&dBUTTONn;
	//	always @(posedge clock_main) irq[20] <= NandButton;		// during interrupt

	always @(posedge clock_main) begin
		if (!rst_n) begin
			button_reg <= 0;
		end else begin
			irq[20] <= NandButton;		// irq when not in reset
			if (NandButton)
//				button_reg <= {{29{1'b0}}, ~dBUTTONn};
				button_reg <= ~dBUTTONn;
			else if (button_ready) begin
				if (mem_wstrb[0]) button_reg <= 0;
//				if (mem_wstrb[0]) button_reg[7:0] <= 0;
//				if (mem_wstrb[1]) button_reg[15:8] <= 0;
//				if (mem_wstrb[2]) button_reg[23:16] <= 0;
//				if (mem_wstrb[3]) button_reg[31:24] <= 0;
			end
		end
	end

	
	
	// ========================= mem_ready & mem_rdata selector =========================



	localparam IDLE = 2'b00;
	localparam WBSTART = 2'b01;
	localparam WBEND = 2'b10;

	reg [1:0] state;

	wire         iomem_valid;
	reg          iomem_ready;
	wire [ 3:0]  iomem_wstrb;
	wire [31:0]  iomem_addr;
	wire [31:0]  iomem_wdata;
	reg  [31:0]  iomem_rdata;

	wire we;
	assign we = (iomem_wstrb[0] | iomem_wstrb[1] | iomem_wstrb[2] | iomem_wstrb[3]);

	assign iomem_valid = mem_valid && (mem_addr >= WB_BASE_ADDR);
	assign iomem_wstrb = mem_wstrb;
	assign iomem_addr = mem_addr;
	assign iomem_wdata = mem_wdata;

	always @(posedge clock_main) begin
		if (!rst_n) begin
			wbm_adr_o <= 0;
			wbm_dat_o <= 0;
			wbm_we_o <= 0;
			wbm_sel_o <= 0;
			wbm_stb_o <= 0;
			wbm_cyc_o <= 0;
			state <= IDLE;
		end else begin
			case (state)
				IDLE: begin
					if (iomem_valid) begin
						wbm_adr_o <= iomem_addr;
						wbm_dat_o <= iomem_wdata;
						wbm_we_o <= we;
						wbm_sel_o <= we ? mem_wstrb : 4'b1111;

						wbm_stb_o <= 1'b1;
						wbm_cyc_o <= 1'b1;
						state <= WBSTART;
					end else begin
						iomem_ready <= 1'b0;

						wbm_stb_o <= 1'b0;
						wbm_cyc_o <= 1'b0;
						wbm_we_o <= 1'b0;
					end
				end
				WBSTART:begin
					if (wbm_ack_i) begin
						iomem_rdata <= wbm_dat_i;
						iomem_ready <= 1'b1;

						state <= WBEND;

						wbm_stb_o <= 1'b0;
						wbm_cyc_o <= 1'b0;
						wbm_we_o <= 1'b0;
					end
				end
				WBEND: begin
					iomem_ready <= 1'b0;

					state <= IDLE;
				end
				default:
					state <= IDLE;
			endcase
		end
	end

	assign mem_ready = rom_ready || ram_ready || 
							// leds_ready || 
							// seg1_ready || seg2_ready ||
							// rgb1_ready || rgb2_ready ||
							button_ready ||
							// sw_ready ||
							uart_div_ready ||
							uart_data_ready && !uart_dat_wait ||
							(iomem_valid && iomem_ready);
							
	assign mem_rdata = 	rom_ready ? romout : 
								ram_ready ? ram_out :
//								leds_ready ? ledreg :
								// seg1_ready ? {27'h0, seg1reg} :
								// seg2_ready ? {27'h0, seg2reg} :
								// rgb1_ready ? {29'h0, rgb1reg} :
								// rgb2_ready ? {29'h0, rgb2reg} :
//								button_ready ? button_reg :
								button_ready ? {29'h0,button_reg} :
								// sw_ready ? {28'h0, SW} :
								uart_div_ready ? uart_div_reg_do :
								uart_data_ready ? uart_dat_do :
								(iomem_valid && iomem_ready) ? iomem_rdata :
								32'h0000_0000;


endmodule
