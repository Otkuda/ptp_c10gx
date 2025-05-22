module eth_rst (
		input  wire       clock,              //              clock.clk
		input  wire       reset,              //              reset.reset
		output wire [0:0] pll_powerdown,      //      pll_powerdown.pll_powerdown
		output wire [0:0] tx_analogreset,     //     tx_analogreset.tx_analogreset
		output wire [0:0] tx_digitalreset,    //    tx_digitalreset.tx_digitalreset
		output wire [0:0] tx_ready,           //           tx_ready.tx_ready
		input  wire [0:0] pll_locked,         //         pll_locked.pll_locked
		input  wire [0:0] pll_select,         //         pll_select.pll_select
		input  wire [0:0] tx_cal_busy,        //        tx_cal_busy.tx_cal_busy
		output wire [0:0] rx_analogreset,     //     rx_analogreset.rx_analogreset
		output wire [0:0] rx_digitalreset,    //    rx_digitalreset.rx_digitalreset
		output wire [0:0] rx_ready,           //           rx_ready.rx_ready
		input  wire [0:0] rx_is_lockedtodata, // rx_is_lockedtodata.rx_is_lockedtodata
		input  wire [0:0] rx_cal_busy         //        rx_cal_busy.rx_cal_busy
	);
endmodule

