	eth_fpll_1250 u0 (
		.pll_refclk0   (_connected_to_pll_refclk0_),   //   input,  width = 1,   pll_refclk0.clk
		.pll_powerdown (_connected_to_pll_powerdown_), //   input,  width = 1, pll_powerdown.pll_powerdown
		.pll_locked    (_connected_to_pll_locked_),    //  output,  width = 1,    pll_locked.pll_locked
		.tx_serial_clk (_connected_to_tx_serial_clk_), //  output,  width = 1, tx_serial_clk.clk
		.pll_cal_busy  (_connected_to_pll_cal_busy_)   //  output,  width = 1,  pll_cal_busy.pll_cal_busy
	);

