vlib work
vlog  ./rtl/wb_soc/*.v ./rtl/wb_soc/ptp_gen.sv ./rtl/picorv32-master/*.v ./rtl/wb_soc/ptp/*.v
vlog ./sim/ptp_gen_tb/ptp_gen_tb.sv
vsim -novopt work.ptp_gen_tb

