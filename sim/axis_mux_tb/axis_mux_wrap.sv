module axis_mux_wrapper #
(
    // Width of AXI stream interfaces in bits
    parameter DATA_WIDTH = 8,
    // Propagate tkeep signal
    parameter KEEP_ENABLE = (DATA_WIDTH>8),
    // tkeep signal width (words per cycle)
    parameter KEEP_WIDTH = ((DATA_WIDTH+7)/8),
    // Propagate tid signal
    parameter ID_ENABLE = 0,
    // tid signal width
    parameter ID_WIDTH = 8,
    // Propagate tdest signal
    parameter DEST_ENABLE = 0,
    // tdest signal width
    parameter DEST_WIDTH = 8,
    // Propagate tuser signal
    parameter USER_ENABLE = 1,
    // tuser signal width
    parameter USER_WIDTH = 1
)
(
    input logic clk,
    input logic rst_n,
    // WB slave interface for gen
    input  logic [31:0] wbs_addr_i,
    input  logic [31:0] wbs_data_i,
    output logic [31:0] wbs_data_o,
    input  logic        wbs_we_i,
    input  logic        wbs_stb_i,
    output logic        wbs_ack_o,

    input  wire [DATA_WIDTH-1:0] s01_axis_tdata,
    input  wire [KEEP_WIDTH-1:0] s01_axis_tkeep,
    input  wire                  s01_axis_tvalid,
    output wire                  s01_axis_tready,
    input  wire                  s01_axis_tlast,
    input  wire [ID_WIDTH-1:0]   s01_axis_tid,
    input  wire [DEST_WIDTH-1:0] s01_axis_tdest,
    input  wire [USER_WIDTH-1:0] s01_axis_tuser,
    // axis mux output
    output logic [DATA_WIDTH-1:0] m_axis_tdata,
    output logic [KEEP_WIDTH-1:0] m_axis_tkeep,
    output logic                  m_axis_tvalid,
    input  logic                  m_axis_tready,
    output logic                  m_axis_tlast,
    output logic [ID_WIDTH-1:0]   m_axis_tid,
    output logic [DEST_WIDTH-1:0] m_axis_tdest,
    output logic [USER_WIDTH-1:0] m_axis_tuser

);

logic [7:0] tdata_ptp;
logic       tvalid_ptp;
logic       tready_ptp;
logic       tlast_ptp;

ptp_gen ptp_gen_inst (
    .clk(clk),
    .rst_n(rst_n),
    .wbs_addr_i(wbs_addr_i),
    .wbs_data_i(wbs_data_i),
    .wbs_data_o(wbs_data_o),
    .wbs_we_i(wbs_we_i),
    .wbs_stb_i(wbs_stb_i),
    .wbs_ack_o(wbs_ack_o),

    .axis_tdata_o(tdata_ptp),
    .axis_tvalid_o(tvalid_ptp),
    .axis_tready_i(tready_ptp),
    .axis_tlast_o(tlast_ptp)
);

axis_arb_mux_wrap_2 #(
    .DATA_WIDTH(DATA_WIDTH),
    .KEEP_ENABLE(KEEP_ENABLE),
    .KEEP_WIDTH(KEEP_WIDTH),
    .ID_ENABLE(ID_ENABLE),
    .DEST_ENABLE(DEST_ENABLE),
    .DEST_WIDTH(DEST_WIDTH),
    .USER_ENABLE(USER_ENABLE),
    .USER_WIDTH(USER_WIDTH),
    .LAST_ENABLE(1)
) axis_arb_mux_inst (
    .clk(clk),
    .rst(!rst_n),
    .s00_axis_tdata(tdata_ptp),
    .s00_axis_tkeep('1),
    .s00_axis_tvalid(tvalid_ptp),
    .s00_axis_tready(tready_ptp),
    .s00_axis_tlast(tlast_ptp),
    .s00_axis_tid('0),
    .s00_axis_tdest('0),
    .s00_axis_tuser('0),

    .s01_axis_tdata(s01_axis_tdata),
    .s01_axis_tkeep(s01_axis_tkeep),
    .s01_axis_tvalid(s01_axis_tvalid),
    .s01_axis_tready(s01_axis_tready),
    .s01_axis_tlast(s01_axis_tlast),
    .s01_axis_tid(s01_axis_tid),
    .s01_axis_tdest(s01_axis_tdest),
    .s01_axis_tuser(s01_axis_tuser),

    .m_axis_tdata(m_axis_tdata),
    .m_axis_tkeep(m_axis_tkeep),
    .m_axis_tvalid(m_axis_tvalid),
    .m_axis_tready(m_axis_tready),
    .m_axis_tlast(m_axis_tlast),
    .m_axis_tid(m_axis_tid),
    .m_axis_tdest(m_axis_tdest),
    .m_axis_tuser(m_axis_tuser)
);

endmodule