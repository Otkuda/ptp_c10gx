if [file exists "work"] {vdel -all}
vlib work

set PROJ_ROOT "./../../.." 

vlog $PROJ_ROOT/wb_uart/vrf/uart_model.sv
vlog $PROJ_ROOT/wb_uart/vrf/uart_model_tb.sv

vsim uart_model_tb 

run -all
