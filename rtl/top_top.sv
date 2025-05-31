`timescale 1ns/1ns
`include "./tss/tss_pkg.svh"


module top_top (
  input        fpga_resetn, // Global reset, low active
  input        sfp_refclkp, // Reference clock for SFP+ from U64
  input 		   c10_clk50m,	// System clock 50MHz
  
  input  [2:0] BUTTONn,     // GPIO, push buttons
  output [3:0] LEDSn,       // LEd

  output 		 TXD,           // UART tx
  input 		 RXD,           // UART rx. PicoRV terminal

  // 1G eth
  output  [1:0]   sfp_txp            , // SFP+ XCVR TX 
  input   [1:0]   sfp_rxp            , // SFP+ XCVR RX 

  // FMC debug
  output          fmc_la_txn8        , // FMC interface single-ended/LVDS interface
  output          fmc_la_txp8        , // FMC interface single-ended/LVDS interface
  output          fmc_la_txn11       , // FMC interface single-ended/LVDS interface
  output          fmc_la_txp11       , // FMC interface single-ended/LVDS interface
  output          fmc_la_txn13       , // FMC interface single-ended/LVDS interface
  output          fmc_la_txp13       , // FMC interface single-ended/LVDS interface
  output          fmc_la_rxn7        , // FMC interface single-ended/LVDS interface
  output          fmc_la_rxp7        , // FMC interface single-ended/LVDS interface

  // SMA
  output          rf_out             , // SMA

  inout   [1:0]   sfp_scl            , // 
  inout   [1:0]   sfp_sda            , // 
  input   [1:0]   sfp_int              // 
);

  // i2c bidir
  wire [1:0] sfp_scl_i;
  wire [1:0] sfp_scl_t;
  wire [1:0] sfp_scl_o;
  wire [1:0] sfp_sda_i;
  wire [1:0] sfp_sda_t;
  wire [1:0] sfp_sda_o;

  genvar i;
  generate
    for (i=0; i<=1; i=i+1) begin : i2c_if
      assign sfp_scl_i[i] = sfp_scl[i];
      assign sfp_scl[i] = sfp_scl_o[i] ? 1'bz : 1'b0;
      assign sfp_sda_i[i] = sfp_sda[i];
      assign sfp_sda[i] = sfp_sda_o[i] ? 1'bz : 1'b0;
    end 
  endgenerate     

  // signals from PHY to MAC
  wire [1:0] gmii_rx_ctrl;
  wire [1:0] gmii_tx_ctrl;
  wire [1:0] gmii_rx_clk;
  wire [1:0] gmii_tx_clk;
  wire [7:0] gmii_rx_d [1:0];
  wire [7:0] gmii_tx_d [1:0];
  wire [1:0] eth_link_up;



// ------------------- Global reset ------------------- 
  wire clean_rst_long_n;
  reg clean_rst_n;

  antibounce antibounce_inst0(
    .clk (c10_clk50m),
    .rst_n(fpga_resetn),

    .i_sig(BUTTONn[2]),
    .o_sig(clean_rst_long_n)
  );

// 50 ms
  reg [21:0] rst_cnt;

  always@(posedge c10_clk50m, negedge clean_rst_long_n) begin
    if (~clean_rst_long_n) begin
      rst_cnt <= 0;
      clean_rst_n <= 1'b1;
    end
    else if (rst_cnt<2500000) begin
      rst_cnt <= rst_cnt + 1;
      clean_rst_n <= 1'b0;
    end else                         
      clean_rst_n <= 1'b1;
  end

  // ------------------- User logic -------------------         

    // 1 sec counter
    reg [25:0] cnt;		  
    always@(posedge c10_clk50m or negedge fpga_resetn)
    begin
        if (~fpga_resetn)
            cnt <= 0;
        else
            cnt <= cnt + 1;
    end

    assign LEDSn[3] = cnt[25]; 


 // PHY level
  eth_phy eth_phy_inst (
    .rst_n (clean_rst_n),
    .sys_clk (c10_clk50m),

    .sfp_txp(sfp_txp),
    .sfp_rxp(sfp_rxp),
    .sfp_refclkp(sfp_refclkp),

    .sfp_scl_i(sfp_scl_i),
    .sfp_scl_t(sfp_scl_t),
    .sfp_scl_o(sfp_scl_o),
    .sfp_sda_i(sfp_sda_i),
    .sfp_sda_t(sfp_sda_t),
    .sfp_sda_o(sfp_sda_o),        

    .gmii_rx_ctrl(gmii_rx_ctrl), // output
    .gmii_rx_d(gmii_rx_d),       // output
    .gmii_rx_clk(gmii_rx_clk),   // output

    .gmii_tx_ctrl(gmii_tx_ctrl), // input
    .gmii_tx_d(gmii_tx_d),       // input
    .gmii_tx_clk(gmii_tx_clk),   // output

    .link_up(eth_link_up),

    .debug()
  );
  assign LEDSn[2:1] = eth_link_up;
  assign LEDSn[0] = gmii_rx_ctrl[0];

  // wishbone bus
  wire [31:0] wbm_adr;
  wire [31:0] wbm_data_w;
  wire [31:0] wbm_data_r;
  wire        wbm_we;
  wire [3:0]  wbm_sel;
  wire        wbm_stb;
  wire        wbm_ack;
  wire        wbm_cyc;

  wire [31:0] wbs_data_w;
  wire [31:0] wbs_addr;

  // ptp slave signals
  wire [31:0] wbs_ptp_data_r;
  wire        wbs_ptp_ack;
  wire        wbs_ptp_cyc;
  wire        wbs_ptp_stb;
  wire        wbs_ptp_we;

  // ptp_gen slave signals
  wire [31:0] wbs_gen_data_r;
  wire        wbs_gen_ack;
  wire        wbs_gen_cyc;
  wire        wbs_gen_stb;
  wire        wbs_gen_we;

  // tss slave signals
  wire [31:0] wbs_tss_data_r;
  wire        wbs_tss_ack;
  wire        wbs_tss_cyc;
  wire        wbs_tss_stb;
  wire        wbs_tss_we;

  top_soc soc_inst (
    .clock_main(gmii_tx_clk[0]),
    .rst_n(clean_rst_n),
    .BUTTONn(BUTTONn[1:0]),
    .LEDSn(),
    .RGB1n(RGB1n),
    .RGB2n(RGB2n),
    .SEG1n(SEG1n),
    .SEG2n(SEG2n),
    .SW(SW),
    .TXD(TXD),
    .RXD(RXD),

    .wbm_adr_o(wbm_adr),
    .wbm_dat_o(wbm_data_w),
    .wbm_dat_i(wbm_data_r),
    .wbm_we_o(wbm_we),
    .wbm_sel_o(wbm_sel),
    .wbm_stb_o(wbm_stb),
    .wbm_ack_i(wbm_ack),
    .wbm_cyc_o(wbm_cyc)
  );

  wb_interconnect #(
      .NUM_SLAVE(3)
    ) intercon_inst (
      .clk(gmii_tx_clk),
      .rst(clean_rst_n),
      
      .i_wbm_cyc(wbm_cyc),
      .i_wbm_stb(wbm_stb),
      .i_wbm_we(wbm_we),
      .i_wbm_addr(wbm_adr),
      .i_wbm_data(wbm_data_w),
      .o_wbm_data(wbm_data_r),
      .o_wbm_ack(wbm_ack),

      .o_wbs_cyc({wbs_tss_cyc, wbs_gen_cyc, wbs_ptp_cyc}),
      .o_wbs_stb({wbs_tss_stb, wbs_gen_stb, wbs_ptp_stb}),
      .o_wbs_we({wbs_tss_we, wbs_gen_we, wbs_ptp_we}),
      .o_wbs_addr(wbs_addr),
      .o_wbs_data(wbs_data_w),
      .i_wbs_data({wbs_tss_data_r, wbs_gen_data_r, wbs_ptp_data_r}),
      .i_wbs_ack({wbs_tss_ack, wbs_gen_ack, wbs_ptp_ack})
    );

  wire pps_out;

  ha1588_wb ptp_inst (
    .clk_i(gmii_tx_clk[0]),
    .rst_i(!clean_rst_n),
    .stb_i(wbs_ptp_stb),
    .we_i(wbs_ptp_we),
    .ack_o(wbs_ptp_ack),
    .adr_i(wbs_addr),
    .dat_i(wbs_data_w),
    .dat_o(wbs_ptp_data_r),
    
    .rtc_clk(gmii_tx_clk[0]),
    .rtc_time_ptp_ns(),
    .rtc_time_ptp_sec(),
    .rtc_time_one_pps(pps_out),
    
    .rx_gmii_clk(gmii_rx_clk[0]),
    .rx_gmii_ctrl(gmii_rx_ctrl[0]),
    .rx_gmii_data(gmii_rx_d[0]),
    .rx_giga_mode(1'h1),
    .tx_gmii_clk(gmii_tx_clk[0]),
    .tx_gmii_ctrl(gmii_tx_ctrl[0]),
    .tx_gmii_data(gmii_tx_d[0]),
    .tx_giga_mode(1'h1)
  );

  wire [7:0] ptp_axis_tdata;
  wire       ptp_axis_tvalid;
  wire       ptp_axis_tready;
  wire       ptp_axis_tlast;

  wire [7:0] tss_axis_tdata;
  wire       tss_axis_tvalid;
  wire       tss_axis_tready;
  wire       tss_axis_tlast;

  ptp_gen ptp_gen_inst (
    .clk(gmii_tx_clk[0]),
    .rst_n(clean_rst_n),
    .wbs_addr_i(wbs_addr),
    .wbs_data_i(wbs_data_w),
    .wbs_data_o(wbs_gen_data_r),
    .wbs_we_i(wbs_gen_we),
    .wbs_stb_i(wbs_gen_stb),
    .wbs_ack_o(wbs_gen_ack),

    .axis_tdata_o(ptp_axis_tdata),
    .axis_tvalid_o(ptp_axis_tvalid),
    .axis_tready_i(ptp_axis_tready),
    .axis_tlast_o(ptp_axis_tlast)
  );

  tss_controller_tx tss_tx_inst (
    .clk(gmii_tx_clk[0]),
    .arst(!clean_rst_n),
    .wbs_we_i(wbs_tss_we),
    .wbs_addr_i(wbs_addr),
    .wbs_data_i(wbs_data_w),
    .wbs_data_o(wbs_tss_data_r),
    .wbs_stb_i(wbs_tss_stb),
    .wbs_ack_o(wbs_tss_ack),

    .timer_valid_i(),
    .timer_i(),
    
    .tss_axis_tdata(tss_axis_tdata),
    .tss_axis_tvalid(tss_axis_tvalid),
    .tss_axis_tready(tss_axis_tready),
    .tss_axis_tlast(tss_axis_tlast)
  );

  gmii_udp_tx #(
    .DATA_WIDTH(8)
  ) gmii_inst (
    .rx_clk(gmii_rx_clk[0]),
    .tx_clk(gmii_tx_clk[0]),
    .logic_clk(gmii_tx_clk[0]),
    .rst(~clean_rst_n),

    .gmii_txd(gmii_tx_d[0]),
    .gmii_tx_en(gmii_tx_ctrl[0]),
    .gmii_tx_er(),
    
    .gmii_rxd(gmii_rx_d[0]),
    .gmii_rx_dv(gmii_rx_ctrl[0]),
    .gmii_rx_er(1'h0),
    
    .tx_tss_udp_payload_axis_tdata(tss_axis_tdata),
    .tx_tss_udp_payload_axis_tvalid(tss_axis_tvalid),
    .tx_tss_udp_payload_axis_tready(tss_axis_tready),
    .tx_tss_udp_payload_axis_tlast(tss_axis_tlast),
    .tx_tss_udp_payload_axis_tuser(),

    .tx_ptp_payload_axis_tdata(ptp_axis_tdata),
    .tx_ptp_payload_axis_tvalid(ptp_axis_tvalid),
    .tx_ptp_payload_axis_tready(ptp_axis_tready),
    .tx_ptp_payload_axis_tlast(ptp_axis_tlast),
    .tx_ptp_payload_axis_tuser()
  );

assign rf_out = pps_out;

endmodule
