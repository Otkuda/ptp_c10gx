	component tse is
		port (
			clk                : in  std_logic                     := 'X';             -- clk
			reset              : in  std_logic                     := 'X';             -- reset
			ref_clk            : in  std_logic                     := 'X';             -- clk
			reg_addr           : in  std_logic_vector(4 downto 0)  := (others => 'X'); -- address
			reg_data_out       : out std_logic_vector(15 downto 0);                    -- readdata
			reg_rd             : in  std_logic                     := 'X';             -- read
			reg_data_in        : in  std_logic_vector(15 downto 0) := (others => 'X'); -- writedata
			reg_wr             : in  std_logic                     := 'X';             -- write
			reg_busy           : out std_logic;                                        -- waitrequest
			tx_clkena          : out std_logic;                                        -- tx_clkena
			rx_clkena          : out std_logic;                                        -- rx_clkena
			gmii_rx_dv         : out std_logic;                                        -- gmii_rx_dv
			gmii_rx_d          : out std_logic_vector(7 downto 0);                     -- gmii_rx_d
			gmii_rx_err        : out std_logic;                                        -- gmii_rx_err
			gmii_tx_en         : in  std_logic                     := 'X';             -- gmii_tx_en
			gmii_tx_d          : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- gmii_tx_d
			gmii_tx_err        : in  std_logic                     := 'X';             -- gmii_tx_err
			mii_rx_dv          : out std_logic;                                        -- mii_rx_dv
			mii_rx_d           : out std_logic_vector(3 downto 0);                     -- mii_rx_d
			mii_rx_err         : out std_logic;                                        -- mii_rx_err
			mii_tx_en          : in  std_logic                     := 'X';             -- mii_tx_en
			mii_tx_d           : in  std_logic_vector(3 downto 0)  := (others => 'X'); -- mii_tx_d
			mii_tx_err         : in  std_logic                     := 'X';             -- mii_tx_err
			mii_col            : out std_logic;                                        -- mii_col
			mii_crs            : out std_logic;                                        -- mii_crs
			set_10             : out std_logic;                                        -- set_10
			set_1000           : out std_logic;                                        -- set_1000
			set_100            : out std_logic;                                        -- set_100
			hd_ena             : out std_logic;                                        -- hd_ena
			tx_clk             : out std_logic;                                        -- clk
			rx_clk             : out std_logic;                                        -- clk
			reset_tx_clk       : in  std_logic                     := 'X';             -- reset
			reset_rx_clk       : in  std_logic                     := 'X';             -- reset
			led_crs            : out std_logic;                                        -- crs
			led_link           : out std_logic;                                        -- link
			led_panel_link     : out std_logic;                                        -- panel_link
			led_col            : out std_logic;                                        -- col
			led_an             : out std_logic;                                        -- an
			led_char_err       : out std_logic;                                        -- char_err
			led_disp_err       : out std_logic;                                        -- disp_err
			tx_analogreset     : in  std_logic_vector(0 downto 0)  := (others => 'X'); -- tx_analogreset
			tx_digitalreset    : in  std_logic_vector(0 downto 0)  := (others => 'X'); -- tx_digitalreset
			rx_analogreset     : in  std_logic_vector(0 downto 0)  := (others => 'X'); -- rx_analogreset
			rx_digitalreset    : in  std_logic_vector(0 downto 0)  := (others => 'X'); -- rx_digitalreset
			tx_cal_busy        : out std_logic_vector(0 downto 0);                     -- tx_cal_busy
			rx_cal_busy        : out std_logic_vector(0 downto 0);                     -- rx_cal_busy
			tx_serial_clk      : in  std_logic_vector(0 downto 0)  := (others => 'X'); -- clk
			rx_cdr_refclk      : in  std_logic                     := 'X';             -- clk
			rx_set_locktodata  : in  std_logic_vector(0 downto 0)  := (others => 'X'); -- rx_set_locktodata
			rx_set_locktoref   : in  std_logic_vector(0 downto 0)  := (others => 'X'); -- rx_set_locktoref
			rx_is_lockedtoref  : out std_logic_vector(0 downto 0);                     -- rx_is_lockedtoref
			rx_is_lockedtodata : out std_logic_vector(0 downto 0);                     -- rx_is_lockedtodata
			rxp                : in  std_logic                     := 'X';             -- rxp
			txp                : out std_logic;                                        -- txp
			rx_recovclkout     : out std_logic                                         -- export
		);
	end component tse;

	u0 : component tse
		port map (
			clk                => CONNECTED_TO_clk,                -- control_port_clock_connection.clk
			reset              => CONNECTED_TO_reset,              --              reset_connection.reset
			ref_clk            => CONNECTED_TO_ref_clk,            --  pcs_ref_clk_clock_connection.clk
			reg_addr           => CONNECTED_TO_reg_addr,           --                  control_port.address
			reg_data_out       => CONNECTED_TO_reg_data_out,       --                              .readdata
			reg_rd             => CONNECTED_TO_reg_rd,             --                              .read
			reg_data_in        => CONNECTED_TO_reg_data_in,        --                              .writedata
			reg_wr             => CONNECTED_TO_reg_wr,             --                              .write
			reg_busy           => CONNECTED_TO_reg_busy,           --                              .waitrequest
			tx_clkena          => CONNECTED_TO_tx_clkena,          --       clock_enable_connection.tx_clkena
			rx_clkena          => CONNECTED_TO_rx_clkena,          --                              .rx_clkena
			gmii_rx_dv         => CONNECTED_TO_gmii_rx_dv,         --               gmii_connection.gmii_rx_dv
			gmii_rx_d          => CONNECTED_TO_gmii_rx_d,          --                              .gmii_rx_d
			gmii_rx_err        => CONNECTED_TO_gmii_rx_err,        --                              .gmii_rx_err
			gmii_tx_en         => CONNECTED_TO_gmii_tx_en,         --                              .gmii_tx_en
			gmii_tx_d          => CONNECTED_TO_gmii_tx_d,          --                              .gmii_tx_d
			gmii_tx_err        => CONNECTED_TO_gmii_tx_err,        --                              .gmii_tx_err
			mii_rx_dv          => CONNECTED_TO_mii_rx_dv,          --                mii_connection.mii_rx_dv
			mii_rx_d           => CONNECTED_TO_mii_rx_d,           --                              .mii_rx_d
			mii_rx_err         => CONNECTED_TO_mii_rx_err,         --                              .mii_rx_err
			mii_tx_en          => CONNECTED_TO_mii_tx_en,          --                              .mii_tx_en
			mii_tx_d           => CONNECTED_TO_mii_tx_d,           --                              .mii_tx_d
			mii_tx_err         => CONNECTED_TO_mii_tx_err,         --                              .mii_tx_err
			mii_col            => CONNECTED_TO_mii_col,            --                              .mii_col
			mii_crs            => CONNECTED_TO_mii_crs,            --                              .mii_crs
			set_10             => CONNECTED_TO_set_10,             --       sgmii_status_connection.set_10
			set_1000           => CONNECTED_TO_set_1000,           --                              .set_1000
			set_100            => CONNECTED_TO_set_100,            --                              .set_100
			hd_ena             => CONNECTED_TO_hd_ena,             --                              .hd_ena
			tx_clk             => CONNECTED_TO_tx_clk,             -- pcs_transmit_clock_connection.clk
			rx_clk             => CONNECTED_TO_rx_clk,             --  pcs_receive_clock_connection.clk
			reset_tx_clk       => CONNECTED_TO_reset_tx_clk,       -- pcs_transmit_reset_connection.reset
			reset_rx_clk       => CONNECTED_TO_reset_rx_clk,       --  pcs_receive_reset_connection.reset
			led_crs            => CONNECTED_TO_led_crs,            --         status_led_connection.crs
			led_link           => CONNECTED_TO_led_link,           --                              .link
			led_panel_link     => CONNECTED_TO_led_panel_link,     --                              .panel_link
			led_col            => CONNECTED_TO_led_col,            --                              .col
			led_an             => CONNECTED_TO_led_an,             --                              .an
			led_char_err       => CONNECTED_TO_led_char_err,       --                              .char_err
			led_disp_err       => CONNECTED_TO_led_disp_err,       --                              .disp_err
			tx_analogreset     => CONNECTED_TO_tx_analogreset,     --                tx_analogreset.tx_analogreset
			tx_digitalreset    => CONNECTED_TO_tx_digitalreset,    --               tx_digitalreset.tx_digitalreset
			rx_analogreset     => CONNECTED_TO_rx_analogreset,     --                rx_analogreset.rx_analogreset
			rx_digitalreset    => CONNECTED_TO_rx_digitalreset,    --               rx_digitalreset.rx_digitalreset
			tx_cal_busy        => CONNECTED_TO_tx_cal_busy,        --                   tx_cal_busy.tx_cal_busy
			rx_cal_busy        => CONNECTED_TO_rx_cal_busy,        --                   rx_cal_busy.rx_cal_busy
			tx_serial_clk      => CONNECTED_TO_tx_serial_clk,      --                 tx_serial_clk.clk
			rx_cdr_refclk      => CONNECTED_TO_rx_cdr_refclk,      --                 rx_cdr_refclk.clk
			rx_set_locktodata  => CONNECTED_TO_rx_set_locktodata,  --             rx_set_locktodata.rx_set_locktodata
			rx_set_locktoref   => CONNECTED_TO_rx_set_locktoref,   --              rx_set_locktoref.rx_set_locktoref
			rx_is_lockedtoref  => CONNECTED_TO_rx_is_lockedtoref,  --             rx_is_lockedtoref.rx_is_lockedtoref
			rx_is_lockedtodata => CONNECTED_TO_rx_is_lockedtodata, --            rx_is_lockedtodata.rx_is_lockedtodata
			rxp                => CONNECTED_TO_rxp,                --             serial_connection.rxp
			txp                => CONNECTED_TO_txp,                --                              .txp
			rx_recovclkout     => CONNECTED_TO_rx_recovclkout      --     serdes_control_connection.export
		);

