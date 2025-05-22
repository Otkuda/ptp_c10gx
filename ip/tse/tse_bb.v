module tse (
		input  wire        clk,                // control_port_clock_connection.clk,               Clock Input
		input  wire        reset,              //              reset_connection.reset,             Reset Input
		input  wire        ref_clk,            //  pcs_ref_clk_clock_connection.clk,               Clock Input
		input  wire [4:0]  reg_addr,           //                  control_port.address
		output wire [15:0] reg_data_out,       //                              .readdata
		input  wire        reg_rd,             //                              .read
		input  wire [15:0] reg_data_in,        //                              .writedata
		input  wire        reg_wr,             //                              .write
		output wire        reg_busy,           //                              .waitrequest
		output wire        tx_clkena,          //       clock_enable_connection.tx_clkena
		output wire        rx_clkena,          //                              .rx_clkena
		output wire        gmii_rx_dv,         //               gmii_connection.gmii_rx_dv
		output wire [7:0]  gmii_rx_d,          //                              .gmii_rx_d
		output wire        gmii_rx_err,        //                              .gmii_rx_err
		input  wire        gmii_tx_en,         //                              .gmii_tx_en
		input  wire [7:0]  gmii_tx_d,          //                              .gmii_tx_d
		input  wire        gmii_tx_err,        //                              .gmii_tx_err
		output wire        mii_rx_dv,          //                mii_connection.mii_rx_dv
		output wire [3:0]  mii_rx_d,           //                              .mii_rx_d
		output wire        mii_rx_err,         //                              .mii_rx_err
		input  wire        mii_tx_en,          //                              .mii_tx_en
		input  wire [3:0]  mii_tx_d,           //                              .mii_tx_d
		input  wire        mii_tx_err,         //                              .mii_tx_err
		output wire        mii_col,            //                              .mii_col
		output wire        mii_crs,            //                              .mii_crs
		output wire        set_10,             //       sgmii_status_connection.set_10
		output wire        set_1000,           //                              .set_1000
		output wire        set_100,            //                              .set_100
		output wire        hd_ena,             //                              .hd_ena
		output wire        tx_clk,             // pcs_transmit_clock_connection.clk
		output wire        rx_clk,             //  pcs_receive_clock_connection.clk
		input  wire        reset_tx_clk,       // pcs_transmit_reset_connection.reset
		input  wire        reset_rx_clk,       //  pcs_receive_reset_connection.reset
		output wire        led_crs,            //         status_led_connection.crs
		output wire        led_link,           //                              .link
		output wire        led_panel_link,     //                              .panel_link
		output wire        led_col,            //                              .col
		output wire        led_an,             //                              .an
		output wire        led_char_err,       //                              .char_err
		output wire        led_disp_err,       //                              .disp_err
		input  wire [0:0]  tx_analogreset,     //                tx_analogreset.tx_analogreset
		input  wire [0:0]  tx_digitalreset,    //               tx_digitalreset.tx_digitalreset
		input  wire [0:0]  rx_analogreset,     //                rx_analogreset.rx_analogreset
		input  wire [0:0]  rx_digitalreset,    //               rx_digitalreset.rx_digitalreset
		output wire [0:0]  tx_cal_busy,        //                   tx_cal_busy.tx_cal_busy
		output wire [0:0]  rx_cal_busy,        //                   rx_cal_busy.rx_cal_busy
		input  wire [0:0]  tx_serial_clk,      //                 tx_serial_clk.clk
		input  wire        rx_cdr_refclk,      //                 rx_cdr_refclk.clk
		input  wire [0:0]  rx_set_locktodata,  //             rx_set_locktodata.rx_set_locktodata
		input  wire [0:0]  rx_set_locktoref,   //              rx_set_locktoref.rx_set_locktoref
		output wire [0:0]  rx_is_lockedtoref,  //             rx_is_lockedtoref.rx_is_lockedtoref
		output wire [0:0]  rx_is_lockedtodata, //            rx_is_lockedtodata.rx_is_lockedtodata
		input  wire        rxp,                //             serial_connection.rxp
		output wire        txp,                //                              .txp
		output wire        rx_recovclkout      //     serdes_control_connection.export
	);
endmodule

