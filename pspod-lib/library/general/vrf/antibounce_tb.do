## part 1: new lib
vlib work
vmap work work

## part 2: load design
vlog antibounce.sv 
vlog antibounce_tb.sv 

## part 3: sim design
vsim -novopt work.antibounce_tb

## part 4: add signals

#add wave                    -label "clk"                        /clk125mhz
add wave                    -label "rst_n"                      /rst_n

add wave                    -label "bounce"                      /bounce

add wave                    -label "cnt"                        /dut/cnt
add wave                    -label "cout"                       /dut/cout

add wave                    -label "clear_signal"               /clear_sig

## part 5: show ui 
view wave
view structure
view signals

## part 6: run 
run 10 ms
