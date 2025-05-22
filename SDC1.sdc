create_clock -period "20.000 ns" -name {clk50} [get_ports {clk}]
set_clock_groups -asynchronous -group [get_clocks {clk50}]

create_clock -period "40.000 ns" -name {altera_reserved_tck} {altera_reserved_tck}
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}]

set_false_path -from [get_ports {BUTTONn[*]}] -to *
set_false_path -from [get_ports {SW[*]}] -to *

set_false_path -from * -to [get_ports {LEDSn[*]}]
set_false_path -from * -to [get_ports {debug[*]}]

#JTAG Signal Constraints
#constrain the TDI TMS and TDO ports  -- (modified from timequest SDC cookbook)
set_input_delay  -clock altera_reserved_tck 5 [get_ports altera_reserved_tdi]
set_input_delay  -clock altera_reserved_tck 5 [get_ports altera_reserved_tms]
set_output_delay -clock altera_reserved_tck -clock_fall -fall -max 5 [get_ports altera_reserved_tdo]

derive_pll_clocks
derive_clock_uncertainty

