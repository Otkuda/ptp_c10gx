`timescale 1ns/1ns
module ptp_gen_tb();

localparam CLK_PERIOD = 20;

logic clk;
logic rst_n;

logic [31:0] wbs_addr_i;
logic [31:0] wbs_data_i;
logic [31:0] wbs_data_o;
logic        wbs_we_i;
logic        wbs_stb_i;
logic        wbs_ack_o;

logic [7:0] axis_tdata_o;
logic       axis_tvalid_o;
logic       axis_tready_i;
logic       axis_tlast_o;

ptp_gen dut (
    .*
);

always #(CLK_PERIOD) clk = ~clk;

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

initial begin
    clk = 0;
    rst_n = 1;
    axis_tready_i = 0;
    #(CLK_PERIOD * 2);
    rst_n = 0;
    #(CLK_PERIOD * 2);
    rst_n = 1;
    wb_send(8'h03000104, {4'h1, 12'h123, 16'h5555});
    wb_send(8'h03000108, 32'h0);
    wb_send(8'h0300010c, 32'h16);
    wb_send(8'h03000110, 32'haaaa);
    #100;
    wb_send(8'h03000000, 32'h1);
    #100;
    axis_tready_i = 1;
    @(negedge axis_tvalid_o);
    #100;
    $stop;
end

endmodule