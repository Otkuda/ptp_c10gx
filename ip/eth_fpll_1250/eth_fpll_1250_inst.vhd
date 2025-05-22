	component eth_fpll_1250 is
		port (
			pll_refclk0   : in  std_logic := 'X'; -- clk
			pll_powerdown : in  std_logic := 'X'; -- pll_powerdown
			pll_locked    : out std_logic;        -- pll_locked
			tx_serial_clk : out std_logic;        -- clk
			pll_cal_busy  : out std_logic         -- pll_cal_busy
		);
	end component eth_fpll_1250;

	u0 : component eth_fpll_1250
		port map (
			pll_refclk0   => CONNECTED_TO_pll_refclk0,   --   pll_refclk0.clk
			pll_powerdown => CONNECTED_TO_pll_powerdown, -- pll_powerdown.pll_powerdown
			pll_locked    => CONNECTED_TO_pll_locked,    --    pll_locked.pll_locked
			tx_serial_clk => CONNECTED_TO_tx_serial_clk, -- tx_serial_clk.clk
			pll_cal_busy  => CONNECTED_TO_pll_cal_busy   --  pll_cal_busy.pll_cal_busy
		);

