if [file exists "work"] {vdel -all}
vlib work

set PROJ_ROOT "./../../.." 

vlog $PROJ_ROOT/wb_uart/vrf/uart_model.sv
vlog $PROJ_ROOT/wb_uart/rtl/systemverilog/uart_transmitter.sv
vlog $PROJ_ROOT/wb_uart/rtl/systemverilog/uart_receiver.sv
vlog $PROJ_ROOT/wb_uart/vrf/uart_rxtx_tb.sv

vsim uart_rxtx_tb 

run -all
