vlib work
vlog ./rtl/ptp_gen.sv ./rtl/axis_arb_mux_wrap_2.v ./rtl/axis_arb_mux.v ./rtl/priority_encoder.v
vlog ./sim/axis_mux_tb/*.sv
vsim -novopt work.axis_mux_tb