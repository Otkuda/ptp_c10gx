module ptp_gen (
  input logic clk,
  input logic rst_n,

  // WB slave interface
  input  logic [31:0] wbs_addr_i,
  input  logic [31:0] wbs_data_i,
  output logic [31:0] wbs_data_o,
  input  logic        wbs_we_i,
  input  logic        wbs_stb_i,
  output logic        wbs_ack_o,
  // AXIs source
  output logic [7:0] axis_tdata_o,
  output logic       axis_tvalid_o,
  input  logic       axis_tready_i,
  output logic       axis_tlast_o
);

localparam CTRL_REG_ADDR = 32'h03000100;
localparam INFO_REG_ADDR = 32'h03000104;
localparam TSSH_REG_ADDR = 32'h03000108;
localparam TSSL_REG_ADDR = 32'h0300010C;
localparam TSNS_REG_ADDR = 32'h03000110;

localparam PTP_HEADER_W = 34 * 8 - 1; 

/*
 * Module generates PTP Delay_Req message and sends it via axis to ethernet MAC
 * 
 */

logic [31:0] gen_ctrl_reg;
logic [31:0] gen_info_reg; // msg_id, checksum, seq_id
logic [79:0] gen_ptp_timestamp;
logic [31:0] gen_ts_sh_reg;
logic [31:0] gen_ts_ns_reg;
logic [31:0] gen_ts_sl_reg;

always_ff @(posedge clk) begin
  if (~rst_n) begin
    gen_ctrl_reg <= '0;
    gen_info_reg <= '0;
    gen_ts_sh_reg <= '0;
    gen_ts_ns_reg <= '0;
    gen_ts_sl_reg <= '0;
  end
  else begin
    if (wbs_stb_i) begin
      if (wbs_we_i) begin
        case (wbs_addr_i)
          CTRL_REG_ADDR: gen_ctrl_reg <= wbs_data_i;
          INFO_REG_ADDR: gen_info_reg <= wbs_data_i;
          TSSH_REG_ADDR: gen_ts_sh_reg <= wbs_data_i;
          TSSL_REG_ADDR: gen_ts_sl_reg <= wbs_data_i;
          TSNS_REG_ADDR: gen_ts_ns_reg <= wbs_data_i;
        endcase
      end
      else begin
        case (wbs_addr_i)
          CTRL_REG_ADDR: wbs_data_o <= gen_ctrl_reg;
          INFO_REG_ADDR: wbs_data_o <= gen_info_reg;
          TSSH_REG_ADDR: wbs_data_o <= gen_ts_sh_reg;
          TSSL_REG_ADDR: wbs_data_o <= gen_ts_sl_reg;
          TSNS_REG_ADDR: wbs_data_o <= gen_ts_ns_reg;
          default: wbs_data_o <= 0;
        endcase
      end
    end else begin
      gen_ctrl_reg <= '0;
    end
  end
end

always_ff @(posedge clk) begin
  if (!rst_n)
    wbs_ack_o <= 0;
  else if (wbs_ack_o)
    wbs_ack_o <= 0;
  else if (wbs_stb_i)
    wbs_ack_o <= 1;
  else
    wbs_ack_o <= 0;
end

assign gen_ptp_timestamp = {gen_ts_sh_reg[15:0], gen_ts_sl_reg, gen_ts_ns_reg};

typedef enum logic [1:0] { IDLE, SEND, LAST } sender_state;
sender_state state = IDLE;

logic [PTP_HEADER_W:0] ptp_header;
assign ptp_header = {
                    4'h0, gen_info_reg[31:28],
                    4'h0, 4'h2,
                    16'h2c, 16'h0,
                    16'h0, 64'h0,
                    32'h0, 64'h0,
                    16'h1, gen_info_reg[15:0],
                    8'h0, 8'hf
                    };

logic [PTP_HEADER_W+80:0] ptp_data;
assign ptp_data = {ptp_header, gen_ptp_timestamp};

logic [15:0] byte_cnt;

always_ff @(posedge clk) begin
  if (!rst_n) begin
    byte_cnt = '0;
    axis_tdata_o <= '0;
    axis_tvalid_o <= '0;
    state <= IDLE;
  end
  else begin
    case (state)
      IDLE: begin
        if (gen_ctrl_reg == 1) begin
          axis_tdata_o <= ptp_data[PTP_HEADER_W+80-byte_cnt*8 -: 8];
          axis_tvalid_o <= '1;
          byte_cnt <= byte_cnt + 1;
          state <= SEND;
        end
        else begin
          state <= IDLE;
          axis_tlast_o <= 0;
          axis_tvalid_o <= '0;
          axis_tdata_o <= '0;
          byte_cnt <= 0;
        end
      end
      SEND: begin
        if (axis_tvalid_o && axis_tready_i) begin
          axis_tdata_o <= ptp_data[PTP_HEADER_W+80-byte_cnt*8 -: 8];
          byte_cnt <= byte_cnt + 1;
          if (byte_cnt == 42) begin
            state <= LAST;
          end
        end
      end
      LAST: begin
        if (axis_tvalid_o && axis_tready_i) begin
          axis_tdata_o <= ptp_data[PTP_HEADER_W+80-byte_cnt*8 -: 8];
          axis_tlast_o <= 1;
          state <= IDLE;
        end
      end
    endcase 
  end
end


endmodule
