`timescale 1 ps / 1 ps

//------------------------------------------------------
// author:	Olga Mamoutova
// email:	olga.mamoutova@spbpu.com
// project: JINR TSS
//------------------------------------------------------
// Wrapper for two SFP PCS/PMA channels with link training
// and autonegotiation
// Target platform: Intel C10GX dev kit
//------------------------------------------------------

module eth_phy 
#(I2C_PRESCALE = 16'd125)   // default for 100 kHz i2c clk and 50 MHz sys clk
(
    //Reset and Clocks
    input           rst_n              , // Global reset, low active
    input           sys_clk            , // System clock e.g. 50MHz

    // 1G eth
    output  [1:0]   sfp_txp            , // SFP+ XCVR TX 
    input   [1:0]   sfp_rxp            , // SFP+ XCVR RX 
    input           sfp_refclkp        , // Reference clock for SFP+ from U64

    // i2c to setup SFP
    input  [1:0] sfp_scl_i,
    output [1:0] sfp_scl_t,
    output [1:0] sfp_scl_o,
    input  [1:0] sfp_sda_i,
    output [1:0] sfp_sda_t,
    output [1:0] sfp_sda_o,

    // GMII
    output  [1:0]   gmii_rx_ctrl       ,
    output  [7:0]   gmii_rx_d [1:0]    ,
    output  [1:0]   gmii_rx_clk        ,

    input   [1:0]   gmii_tx_ctrl       ,
    input   [7:0]   gmii_tx_d [1:0]    ,
    output  [1:0]   gmii_tx_clk        ,

    // status
    output  [1:0]   link_up            ,

    output  [7:0]   debug
);

    wire tx_serial_1250_clk;
    wire [1:0] pll_powerdown;
	wire pll_locked, pll_cal_busy;
    wire [1:0] tx_cal_busy;
    wire [1:0] rx_cal_busy;
    wire [1:0] rx_is_lockedtodata;
    wire [1:0] rx_is_lockedtoref;
    wire [1:0] tx_digitalreset;
    wire [1:0] tx_analogreset;
    wire [1:0] rx_digitalreset;
    wire [1:0] rx_analogreset;

    wire [1:0] tx_rst_ready;
    wire [1:0] rx_rst_ready;

    // ------------------- I2C interface to init SFP ------- 

    reg [1:0] i2c_start_reg;
    wire i2c_start;
    
    always@(posedge sys_clk or negedge rst_n) begin
        if (~rst_n)
            i2c_start_reg <= '0;
        else
            i2c_start_reg <= {i2c_start_reg[0], 1'b1};
    end

    assign i2c_start = (^i2c_start_reg == 1'b1);

    wire [6:0]  axis_cmd_address [1:0];
    wire [1:0]  axis_cmd_start;
    wire [1:0]  axis_cmd_read;
    wire [1:0]  axis_cmd_write;
    wire [1:0]  axis_cmd_write_multiple;
    wire [1:0]  axis_cmd_stop;
    wire [1:0]  axis_cmd_valid;
    wire [1:0]  axis_cmd_ready;
    
    wire [7:0]  axis_data_tdata [1:0];
    wire [1:0]  axis_data_tvalid;
    wire [1:0]  axis_data_tready;
    wire [1:0]  axis_data_tlast;

    i2c_init_sfp i2c_init_sfp_inst[1:0](
        .clk(sys_clk),
        .rst(~rst_n),

        // I2C master interface
        .m_axis_cmd_address(axis_cmd_address),               // output wire [6:0]
        .m_axis_cmd_start(axis_cmd_start),                   // output wire
        .m_axis_cmd_read(axis_cmd_read),                     // output wire  
        .m_axis_cmd_write(axis_cmd_write),                   // output wire
        .m_axis_cmd_write_multiple(axis_cmd_write_multiple), // output wire  
        .m_axis_cmd_stop(axis_cmd_stop),                     // output wire
        .m_axis_cmd_valid(axis_cmd_valid),                   // output wire
        .m_axis_cmd_ready(axis_cmd_ready),                   // input wire

        .m_axis_data_tdata(axis_data_tdata),         // output wire [7:0]
        .m_axis_data_tvalid(axis_data_tvalid),        // output wire
        .m_axis_data_tready(axis_data_tready),        // input  wire
        .m_axis_data_tlast(axis_data_tlast),         // output wire 

        // Status
        .busy(),                       // output wire

        // Configuration
        .start(i2c_start)                       // input  wire
    );

    i2c_master i2c_master_inst[1:0] (
        .clk(sys_clk),
        .rst(~rst_n),

        //Host interface
        .s_axis_cmd_address(axis_cmd_address),              
        .s_axis_cmd_start(axis_cmd_start),                  
        .s_axis_cmd_read(axis_cmd_read),                    
        .s_axis_cmd_write(axis_cmd_write),                  
        .s_axis_cmd_write_multiple(axis_cmd_write_multiple),
        .s_axis_cmd_stop(axis_cmd_stop),                    
        .s_axis_cmd_valid(axis_cmd_valid),                  
        .s_axis_cmd_ready(axis_cmd_ready),                  

        .s_axis_data_tdata(axis_data_tdata),  
        .s_axis_data_tvalid(axis_data_tvalid),
        .s_axis_data_tready(axis_data_tready),
        .s_axis_data_tlast(axis_data_tlast),  

        .m_axis_data_tdata(),
        .m_axis_data_tvalid(),
        .m_axis_data_tready(1'b0),
        .m_axis_data_tlast(),

        //I2C interface
        .scl_i(sfp_scl_i),
        .scl_o(sfp_scl_o),
        .scl_t(sfp_scl_t),
        .sda_i(sfp_sda_i),
        .sda_o(sfp_sda_o),
        .sda_t(sfp_sda_t),

        //Status
        .busy(),
        .bus_control(),
        .bus_active(),
        .missed_ack(),
        
        //Configuration
        .prescale(I2C_PRESCALE),
        .stop_on_idle(1'b0)
    );

    // ------------------- TSE x2 ------------------- 
    wire [1:0] pma_rx_recovclkout;
    wire [1:0] tse_crs;
    wire [1:0] tse_link;
    wire [1:0] tse_link_panel;
    wire [1:0] tse_an;
    wire [1:0] tse_char_err;
    wire [1:0] tse_disp_err;
	
    tse tse_pcs_only_inst[1:0] (
		.reset              (~rst_n),              //   input,   width = 1,              reset_connection.reset
        // 125 MHz local reference clock oscillator
        .ref_clk            (sfp_refclkp),            //   input,   width = 1,  pcs_ref_clk_clock_connection.clk
		// --- PCS Control, should work in aneg+no loopback mode by default
		.clk                (sys_clk),                //   input,   width = 1, control_port_clock_connection.clk
		.reg_addr           ('0),           //   input,   width = 5,                  control_port.address
		.reg_data_out       (),       //  output,  width = 16,                              .readdata
		.reg_rd             ('0),             //   input,   width = 1,                              .read
		.reg_data_in        ('0),        //   input,  width = 16,                              .writedata
		.reg_wr             ('0),             //   input,   width = 1,                              .write
		.reg_busy           (),           //  output,   width = 1,   
        // --- GMII                           .waitrequest
		.gmii_rx_dv         (gmii_rx_ctrl),         //  output,   width = 1,               gmii_connection.gmii_rx_dv
		.gmii_rx_d          (gmii_rx_d),          //  output,   width = 8,                              .gmii_rx_d
		.gmii_rx_err        (),        //  output,   width = 1,                              .gmii_rx_err
		.gmii_tx_en         (gmii_tx_ctrl),         //   input,   width = 1,                              .gmii_tx_en
		.gmii_tx_d          (gmii_tx_d),          //   input,   width = 8,                              .gmii_tx_d
		.gmii_tx_err        (1'b0),        //   input,   width = 1,                              .gmii_tx_err
		// GMII/RGMII/MII transmit clock. 
        // Provides the timing reference for all GMII / MII transmit signals.
        .tx_clk             (gmii_tx_clk),             //  output,   width = 1, pcs_transmit_clock_connection.clk
        // GMII/RGMII/MII receive clock. 
        // Provides the timing reference for all rx related signals.
		.rx_clk             (gmii_rx_clk),             //  output,   width = 1,  pcs_receive_clock_connection.clk
		.reset_tx_clk       (~rst_n),       //   input,   width = 1, pcs_transmit_reset_connection.reset
		.reset_rx_clk       (~rst_n),       //   input,   width = 1,  pcs_receive_reset_connection.reset
		// --- Status
        // When asserted, this signal indicates some activities on
        // the transmit and receive paths. When deasserted, it 
        // indicates no traffic on the paths.
        .led_crs            (tse_crs),            //  output,   width = 1,         status_led_connection.crs
		// When asserted, this signal indicates a successful link synchronization.
        .led_link           (tse_link),           //  output,   width = 1,                              .link
		.led_panel_link     (tse_link_panel),     //  output,   width = 1,                              .panel_link
		.led_col            (),            //  output,   width = 1,                              .col
		.led_an             (tse_an),             //  output,   width = 1,                              .an
		.led_char_err       (tse_char_err),       //  output,   width = 1,                              .char_err
		.led_disp_err       (tse_disp_err),       //  output,   width = 1,                              .disp_err
		// --- to PHY reset and PLL
        .tx_analogreset     (tx_analogreset),     //   input,   width = 1,                tx_analogreset.tx_analogreset
		.tx_digitalreset    (tx_digitalreset),    //   input,   width = 1,               tx_digitalreset.tx_digitalreset
		.rx_analogreset     (rx_analogreset),     //   input,   width = 1,                rx_analogreset.rx_analogreset
		.rx_digitalreset    (rx_digitalreset),    //   input,   width = 1,               rx_digitalreset.rx_digitalreset
		.tx_cal_busy        (tx_cal_busy),        //  output,   width = 1,                   tx_cal_busy.tx_cal_busy
		.rx_cal_busy        (rx_cal_busy),        //  output,   width = 1,                   rx_cal_busy.rx_cal_busy
		// Serial clock input from the transceiver PLL. 
        // The frequency of this clock is 1250 MHz and the division 
        // factor is fixed to divide by 2.
        .tx_serial_clk      (tx_serial_1250_clk),      //   input,   width = 1,                 tx_serial_clk.clk
		// Reference clock input to the receive clock data recovery (CDR) 
        // circuitry. The frequency of this clock is 125 MHz.
        .rx_cdr_refclk      (sfp_refclkp),      //   input,   width = 1,                 rx_cdr_refclk.clk
		.rx_set_locktodata  (1'b0),  //   input,   width = 1,             rx_set_locktodata.rx_set_locktodata
		.rx_set_locktoref   (1'b0),   //   input,   width = 1,              rx_set_locktoref.rx_set_locktoref
		.rx_is_lockedtoref  (rx_is_lockedtoref),  //  output,   width = 1,             rx_is_lockedtoref.rx_is_lockedtoref
		.rx_is_lockedtodata (rx_is_lockedtodata), //  output,   width = 1,            rx_is_lockedtodata.rx_is_lockedtodata
		// --- Serial signals
        .rxp                (sfp_rxp),                //   input,   width = 1,             serial_connection.rxp
		.txp                (sfp_txp),                //  output,   width = 1,                              .txp
		.rx_recovclkout     (pma_rx_recovclkout)      //  output,   width = 1,     serdes_control_connection.export
 	);

    assign link_up = tse_link_panel;

	eth_fpll_1250 eth_fpll_1250_inst (
		.pll_refclk0   (sfp_refclkp),   //   input,  width = 1,   pll_refclk0.clk
		.pll_powerdown (|pll_powerdown), //   input,  width = 1, pll_powerdown.pll_powerdown
		.pll_locked    (pll_locked),    //  output,  width = 1,    pll_locked.pll_locked
		.tx_serial_clk (tx_serial_1250_clk), //  output,  width = 1, tx_serial_clk.clk
		.pll_cal_busy  (pll_cal_busy)   //  output,  width = 1,  pll_cal_busy.pll_cal_busy
	);        

    // ------------------- PHY reset -------------------

	eth_rst eth_rst_inst[1:0] (
		.clock              (sys_clk),              //   input,  width = 1,              clock.clk
		.reset              (~rst_n),              //   input,  width = 1,              reset.reset
		.pll_powerdown      (pll_powerdown),      //  output,  width = 1,      pll_powerdown.pll_powerdown
		.tx_analogreset     (tx_analogreset),     //  output,  width = 1,     tx_analogreset.tx_analogreset
		.tx_digitalreset    (tx_digitalreset),    //  output,  width = 1,    tx_digitalreset.tx_digitalreset
		.tx_ready           (tx_rst_ready),           //  output,  width = 1,           tx_ready.tx_ready
		.pll_locked         (pll_locked),         //   input,  width = 1,         pll_locked.pll_locked
		.pll_select         (1'b0),         //?   input,  width = 1,         pll_select.pll_select
		.tx_cal_busy        (tx_cal_busy | pll_cal_busy),        //   input,  width = 1,        tx_cal_busy.tx_cal_busy
		.rx_analogreset     (rx_analogreset),     //  output,  width = 1,     rx_analogreset.rx_analogreset
		.rx_digitalreset    (rx_digitalreset),    //  output,  width = 1,    rx_digitalreset.rx_digitalreset
		.rx_ready           (rx_rst_ready),           //  output,  width = 1,           rx_ready.rx_ready
		.rx_is_lockedtodata (rx_is_lockedtodata), //   input,  width = 1, rx_is_lockedtodata.rx_is_lockedtodata
		.rx_cal_busy        (rx_cal_busy)         //   input,  width = 1,        rx_cal_busy.rx_cal_busy
	);

    // ------------------- Debug ------------------- 

	assign debug = {
        rx_rst_ready,
        tx_rst_ready,
        rx_is_lockedtodata,
        tse_link_panel
    };

endmodule