create_clock -period "20.000 ns" -name {clk50} [get_ports {c10_clk50m}]
set_clock_groups -asynchronous -group [get_clocks {clk50}]

create_clock -name {xcvr_clk} -period 8.000 -waveform { 0.000 4.000 } [get_ports {sfp_refclkp}]
set_clock_groups -asynchronous -group [get_clocks {xcvr_clk}]

create_clock -period "40.000 ns" -name {altera_reserved_tck} {altera_reserved_tck}
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}]

set_false_path -from [get_ports {BUTTONn[*]}] -to *
set_false_path -from [get_ports {SW[*]}] -to *

set_false_path -from * -to [get_ports {LEDSn[*]}]

#JTAG Signal Constraints
#constrain the TDI TMS and TDO ports  -- (modified from timequest SDC cookbook)
set_input_delay  -clock altera_reserved_tck 5 [get_ports altera_reserved_tdi]
set_input_delay  -clock altera_reserved_tck 5 [get_ports altera_reserved_tms]
set_output_delay -clock altera_reserved_tck -clock_fall -fall -max 5 [get_ports altera_reserved_tdo]

set_clock_uncertainty -rise_from [get_clocks {clk50}] -rise_to [get_clocks {clk50}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk50}] -fall_to [get_clocks {clk50}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clk50}] -rise_to [get_clocks {xcvr_clk}]  0.150  
set_clock_uncertainty -rise_from [get_clocks {clk50}] -fall_to [get_clocks {xcvr_clk}]  0.150  
set_clock_uncertainty -fall_from [get_clocks {clk50}] -rise_to [get_clocks {clk50}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk50}] -fall_to [get_clocks {clk50}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clk50}] -rise_to [get_clocks {xcvr_clk}]  0.150  
set_clock_uncertainty -fall_from [get_clocks {clk50}] -fall_to [get_clocks {xcvr_clk}]  0.150  
set_clock_uncertainty -rise_from [get_clocks {xcvr_clk}] -rise_to [get_clocks {xcvr_clk}]  0.190  
set_clock_uncertainty -rise_from [get_clocks {xcvr_clk}] -fall_to [get_clocks {xcvr_clk}]  0.190  
set_clock_uncertainty -fall_from [get_clocks {xcvr_clk}] -rise_to [get_clocks {xcvr_clk}]  0.190  
set_clock_uncertainty -fall_from [get_clocks {xcvr_clk}] -fall_to [get_clocks {xcvr_clk}]  0.190  

derive_pll_clocks
derive_clock_uncertainty

