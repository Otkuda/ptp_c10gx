if [file exists "work"] {vdel -all}
vlib work

set PROJ_ROOT "./../../.." 

vlog $PROJ_ROOT/wb_uart/rtl/systemverilog/wb_uart.sv
vlog $PROJ_ROOT/wb_uart/rtl/systemverilog/uart_transmitter.sv
vlog $PROJ_ROOT/wb_uart/rtl/systemverilog/uart_receiver.sv

vlog $PROJ_ROOT/wb_uart/vrf/uart_model.sv
vlog $PROJ_ROOT/wb_uart/vrf/wb_uart_tb.sv

#wishbone
vlog +incdir+$PROJ_ROOT/wishbone/sim/ $PROJ_ROOT/wishbone/sim/wb_bfm_master.v

vlog $PROJ_ROOT/wishbone/rtl/systemverilog/wb_if.sv
vlog +incdir+$PROJ_ROOT/wishbone/rtl/systemverilog/ $PROJ_ROOT/wishbone/sim/wb_bfm_master_wrp.sv

#misc
vlog $PROJ_ROOT/memory/rtl/verilog/fifo_fwft_adapter.v
vlog $PROJ_ROOT/memory/rtl/verilog/fifo_fwft.v
vlog $PROJ_ROOT/memory/rtl/verilog/fifo.v
vlog $PROJ_ROOT/memory/rtl/verilog/simple_dpram_sclk.v

# -suppress 14408 -suppress 7063
vopt wb_uart_tb -o top_optimized +acc
# -suppress 16154
#
if { $::argc > 0 } {
    vsim top_optimized $1 $2 -suppress 3009 -sv_seed random
} else {
    vsim top_optimized -suppress 3009 -sv_seed random
}

do wave.do

run -all

wave zoom full
