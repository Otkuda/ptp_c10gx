
// Author: Алексей Головченко для дефектоскопа
// Wishbone B3

`include "wb_if_defs.svh"

`default_nettype none

module wb_bfm_master_wrp #(
    parameter MAX_BURST_LEN   = 32,
    parameter MAX_WAIT_STATES = 8,
    parameter VERBOSE         = 0
)(
    input wire  clk_i,
    input wire  rst_i,
    wb_if.mst   wbm
);
    wb_bfm_master #(
        .aw              (`WB_ADR_MAX_WIDTH ),
        .dw              (`WB_DAT_MAX_WIDTH ),
        .Tp              (0),
        .MAX_BURST_LEN   (MAX_BURST_LEN),
        .MAX_WAIT_STATES (MAX_WAIT_STATES),
        .VERBOSE         (VERBOSE)
    ) inst (
        .wb_clk_i  (clk_i),
        .wb_rst_i  (rst_i),
        .wb_adr_o  (wbm.adr),
        .wb_dat_o  (wbm.dat_m2s),
        .wb_sel_o  (wbm.sel),
        .wb_we_o   (wbm.we),
        .wb_cyc_o  (wbm.cyc),
        .wb_stb_o  (wbm.stb),
        .wb_cti_o  (wbm.cti),
        .wb_bte_o  (wbm.bte),
        .wb_dat_i  (wbm.dat_s2m),
        .wb_ack_i  (wbm.ack),
        .wb_err_i  (wbm.err),
        .wb_rty_i  (wbm.rty)
    );

    task automatic single_read(int addr, output bit [31:0] d);
        inst.addr = addr;
        inst.op = 0;
        inst.init();
        inst.next();
        randcase
            1: inst.wait_states = $urandom_range(0,1);
            4: inst.wait_states = 0;
        endcase
        inst.insert_wait_states;
        d = inst.data;
    endtask

    task automatic single_write(int addr, bit [31:0] d);
        bit err;
        randcase
            1: inst.wait_states = $urandom_range(5,10);
            4: inst.wait_states = 0;
        endcase
        inst.write(addr, d, '1, err);
    endtask

    task automatic wait_read_valie(int addr, int mask, int exp_value);
        int rd;
        forever begin
            wb_bfm_master_wrp.single_read(addr, rd);
            rd = rd & mask;
            if (rd == exp_value)
                break;
        end
    endtask

    task automatic check_read_valie(int addr, int mask, int exp_value, output bit d);
        int rd;        
        wb_bfm_master_wrp.single_read(addr, rd);
        rd = rd & mask;
        if (rd == exp_value)
            d = 1;
        else
            d = 0;
        randcase
            1: inst.wait_states = $urandom_range(0,1);
            4: inst.wait_states = 0;
        endcase
        inst.insert_wait_states;        
    endtask    

    typedef bit [3:0][7:0] data_queue_t [$];

    task automatic multiple_read_same_addr(int addr, int len, ref data_queue_t dat);
        int rd;
        repeat (len) begin
            single_read(addr, rd);
            dat.push_back(rd);
        end
    endtask

endmodule

`default_nettype wire
