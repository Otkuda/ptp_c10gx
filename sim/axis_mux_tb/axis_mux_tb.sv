`timescale 1ns/1ns
module axis_mux_tb();

// Width of AXI stream interfaces in bits
localparam DATA_WIDTH = 8;
// Propagate tkeep signal
localparam KEEP_ENABLE = (DATA_WIDTH>8);
// tkeep signal width (words per cycle)
localparam KEEP_WIDTH = ((DATA_WIDTH+7)/8);
// Propagate tid signal
localparam ID_ENABLE = 0;
// tid signal width
localparam ID_WIDTH = 8;
// Propagate tdest signal
localparam DEST_ENABLE = 0;
// tdest signal width
localparam DEST_WIDTH = 8;
// Propagate tuser signal
localparam USER_ENABLE = 1;
// tuser signal width
localparam USER_WIDTH = 1;

localparam CLK_PERIOD = 20;

logic clk, rst_n;
logic [31:0] wbs_addr_i;
logic [31:0] wbs_data_i;
logic [31:0] wbs_data_o;
logic        wbs_we_i;
logic        wbs_stb_i;
logic        wbs_ack_o;

logic [DATA_WIDTH-1:0] s01_axis_tdata;
logic [KEEP_WIDTH-1:0] s01_axis_tkeep;
logic                  s01_axis_tvalid;
logic                  s01_axis_tready;
logic                  s01_axis_tlast;
logic [ID_WIDTH-1:0]   s01_axis_tid;
logic [DEST_WIDTH-1:0] s01_axis_tdest;
logic [USER_WIDTH-1:0] s01_axis_tuser;

logic [DATA_WIDTH-1:0] m_axis_tdata;
logic [KEEP_WIDTH-1:0] m_axis_tkeep;
logic                  m_axis_tvalid;
logic                  m_axis_tready;
logic                  m_axis_tlast;
logic [ID_WIDTH-1:0]   m_axis_tid;
logic [DEST_WIDTH-1:0] m_axis_tdest;
logic [USER_WIDTH-1:0] m_axis_tuser;


axis_mux_wrapper dut (
    .*
);

task wb_send(input [31:0] addr, data);
    wbs_addr_i = addr;
    wbs_data_i = data;
    wbs_we_i = 1;
    @(posedge clk);
    wbs_stb_i = 1;
    @(negedge wbs_ack_o);
    wbs_stb_i = 0;
    wbs_data_i = '0;
    wbs_addr_i = '0;
endtask

task axi_send(input [7:0] cycles);
    s01_axis_tvalid = 1;
    s01_axis_tdata = 8'ha5;
    @(posedge s01_axis_tready);
    #((cycles-1) * CLK_PERIOD);
    s01_axis_tlast = 1;
    #(CLK_PERIOD);
    s01_axis_tlast = 0;
    s01_axis_tvalid = 0;
endtask

always #(CLK_PERIOD / 2) clk = !clk;

initial begin
    clk = '0;
    rst_n = '0;
    wbs_addr_i = '0;
    wbs_data_i = '0;
    wbs_we_i = '0;
    wbs_stb_i = '0;
    s01_axis_tdata = '0;
    s01_axis_tkeep = '0;
    s01_axis_tvalid = '0;
    s01_axis_tlast = '0;
    s01_axis_tid = '0;
    s01_axis_tdest = '0;
    s01_axis_tuser = '0;
    m_axis_tready = '0;
end

initial begin
    #(CLK_PERIOD * 2);
    rst_n = '1;
    wb_send(32'h03000104, {4'h1, 12'h123, 16'h5555});
    wb_send(32'h03000108, 32'h0);
    wb_send(32'h0300010c, 32'h16);
    wb_send(32'h03000110, 32'haaaa);
    #100;
    wb_send(32'h03000100, 32'h1);

    #500;
    m_axis_tready = 1;
    #500;
    axi_send(8'h8);
    #5000;
    $stop;
end

endmodule