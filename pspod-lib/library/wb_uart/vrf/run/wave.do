onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group {UART REGS} -group WB /wb_uart_tb/dut/wbs/clk
add wave -noupdate -group {UART REGS} -group WB /wb_uart_tb/dut/wbs/rst
add wave -noupdate -group {UART REGS} -group WB /wb_uart_tb/dut/wbs/dat_s2m
add wave -noupdate -group {UART REGS} -group WB /wb_uart_tb/dut/wbs/dat_m2s
add wave -noupdate -group {UART REGS} -group WB /wb_uart_tb/dut/wbs/cyc
add wave -noupdate -group {UART REGS} -group WB /wb_uart_tb/dut/wbs/stb
add wave -noupdate -group {UART REGS} -group WB /wb_uart_tb/dut/wbs/we
add wave -noupdate -group {UART REGS} -group WB /wb_uart_tb/dut/wbs/adr
add wave -noupdate -group {UART REGS} -group WB /wb_uart_tb/dut/wbs/sel
add wave -noupdate -group {UART REGS} -group WB /wb_uart_tb/dut/wbs/ack
add wave -noupdate -group {UART REGS} -group WB /wb_uart_tb/dut/wbs/err
add wave -noupdate -group {UART REGS} -group WB /wb_uart_tb/dut/wbs/rty
add wave -noupdate -group {UART REGS} -group WB /wb_uart_tb/dut/wbs/cti
add wave -noupdate -group {UART REGS} -group WB /wb_uart_tb/dut/wbs/bte
add wave -noupdate -group {UART REGS} /wb_uart_tb/dut/wb_regs_inst/clk_i
add wave -noupdate -group {UART REGS} /wb_uart_tb/dut/wb_regs_inst/rst_i
add wave -noupdate -group {UART REGS} /wb_uart_tb/dut/wb_regs_inst/rx_rempty_i
add wave -noupdate -group {UART REGS} /wb_uart_tb/dut/wb_regs_inst/rx_rnum_i
add wave -noupdate -group {UART REGS} /wb_uart_tb/dut/wb_regs_inst/rx_rena_o
add wave -noupdate -group {UART REGS} /wb_uart_tb/dut/wb_regs_inst/rx_rdat_i
add wave -noupdate -group {UART REGS} /wb_uart_tb/dut/wb_regs_inst/tx_wfull_i
add wave -noupdate -group {UART REGS} /wb_uart_tb/dut/wb_regs_inst/tx_wnum_i
add wave -noupdate -group {UART REGS} /wb_uart_tb/dut/wb_regs_inst/tx_wena_o
add wave -noupdate -group {UART REGS} /wb_uart_tb/dut/wb_regs_inst/tx_wdat_o
add wave -noupdate -group {UART REGS} /wb_uart_tb/dut/wb_regs_inst/tx_ena_o
add wave -noupdate -group {UART REGS} /wb_uart_tb/dut/wb_regs_inst/wb_adr
add wave -noupdate -group {UART REGS} /wb_uart_tb/dut/wb_regs_inst/tx_wdat
add wave -noupdate -group {UART REGS} /wb_uart_tb/dut/wb_regs_inst/tx_ena
add wave -noupdate -group {UART REGS} /wb_uart_tb/dut/wb_regs_inst/rx_rena
add wave -noupdate -group {UART REGS} /wb_uart_tb/dut/wb_regs_inst/tx_wena
add wave -noupdate -group {UART REGS} /wb_uart_tb/dut/wb_regs_inst/rx_rena_w
add wave -noupdate -group {UART REGS} /wb_uart_tb/dut/wb_regs_inst/tx_wena_w
add wave -noupdate -expand -group {UART TX FIFO} /wb_uart_tb/dut/tx_fifo/clk
add wave -noupdate -expand -group {UART TX FIFO} /wb_uart_tb/dut/tx_fifo/rst
add wave -noupdate -expand -group {UART TX FIFO} /wb_uart_tb/dut/tx_fifo/din
add wave -noupdate -expand -group {UART TX FIFO} /wb_uart_tb/dut/tx_fifo/wr_en
add wave -noupdate -expand -group {UART TX FIFO} /wb_uart_tb/dut/tx_fifo/full
add wave -noupdate -expand -group {UART TX FIFO} /wb_uart_tb/dut/tx_fifo/dout
add wave -noupdate -expand -group {UART TX FIFO} /wb_uart_tb/dut/tx_fifo/rd_en
add wave -noupdate -expand -group {UART TX FIFO} /wb_uart_tb/dut/tx_fifo/empty
add wave -noupdate -group {UART TX} /wb_uart_tb/dut/uart_tx/SMPL_N
add wave -noupdate -group {UART TX} /wb_uart_tb/dut/uart_tx/clk_i
add wave -noupdate -group {UART TX} /wb_uart_tb/dut/uart_tx/rst_i
add wave -noupdate -group {UART TX} /wb_uart_tb/dut/uart_tx/baud_div_i
add wave -noupdate -group {UART TX} /wb_uart_tb/dut/uart_tx/data_i
add wave -noupdate -group {UART TX} /wb_uart_tb/dut/uart_tx/req_i
add wave -noupdate -group {UART TX} /wb_uart_tb/dut/uart_tx/done_o
add wave -noupdate -group {UART TX} /wb_uart_tb/dut/uart_tx/ready_o
add wave -noupdate -group {UART TX} /wb_uart_tb/dut/uart_tx/tx_o
add wave -noupdate -group {UART TX} /wb_uart_tb/dut/uart_tx/state
add wave -noupdate -group {UART TX} /wb_uart_tb/dut/uart_tx/baud_div
add wave -noupdate -group {UART TX} /wb_uart_tb/dut/uart_tx/baudcnt
add wave -noupdate -group {UART TX} /wb_uart_tb/dut/uart_tx/baud_tick
add wave -noupdate -group {UART TX} /wb_uart_tb/dut/uart_tx/smplcnt
add wave -noupdate -group {UART TX} /wb_uart_tb/dut/uart_tx/datcnt
add wave -noupdate -group {UART TX} /wb_uart_tb/dut/uart_tx/data_r
add wave -noupdate -group {UART TX} /wb_uart_tb/dut/uart_tx/data_sh_ena
add wave -noupdate -group {UART MODEL RX} /wb_uart_tb/model/rx_i
add wave -noupdate -group {UART MODEL RX} /wb_uart_tb/model/rx_data
add wave -noupdate -group {UART MODEL RX} /wb_uart_tb/model/rx_state
add wave -noupdate -group {UART MODEL TX} /wb_uart_tb/model/tx_data
add wave -noupdate -group {UART MODEL TX} /wb_uart_tb/model/tx_o
add wave -noupdate -group {UART MODEL TX} /wb_uart_tb/model/tx_state
add wave -noupdate -expand -group {UART RX} /wb_uart_tb/dut/uart_rx/baud_div
add wave -noupdate -expand -group {UART RX} /wb_uart_tb/dut/uart_rx/baud_div_i
add wave -noupdate -expand -group {UART RX} /wb_uart_tb/dut/uart_rx/baud_tick
add wave -noupdate -expand -group {UART RX} /wb_uart_tb/dut/uart_rx/baudcnt
add wave -noupdate -expand -group {UART RX} /wb_uart_tb/dut/uart_rx/clk_i
add wave -noupdate -expand -group {UART RX} /wb_uart_tb/dut/uart_rx/data_o
add wave -noupdate -expand -group {UART RX} /wb_uart_tb/dut/uart_rx/datcnt
add wave -noupdate -expand -group {UART RX} /wb_uart_tb/dut/uart_rx/MAJORITY_VOTE
add wave -noupdate -expand -group {UART RX} /wb_uart_tb/dut/uart_rx/rd_data_ena
add wave -noupdate -expand -group {UART RX} /wb_uart_tb/dut/uart_rx/ready_o
add wave -noupdate -expand -group {UART RX} /wb_uart_tb/dut/uart_rx/rst_i
add wave -noupdate -expand -group {UART RX} /wb_uart_tb/dut/uart_rx/rx_fltrd
add wave -noupdate -expand -group {UART RX} /wb_uart_tb/dut/uart_rx/rx_i
add wave -noupdate -expand -group {UART RX} /wb_uart_tb/dut/uart_rx/SMPL_N
add wave -noupdate -expand -group {UART RX} /wb_uart_tb/dut/uart_rx/smplcnt
add wave -noupdate -expand -group {UART RX} /wb_uart_tb/dut/uart_rx/state
add wave -noupdate -expand -group {UART RX} /wb_uart_tb/dut/uart_rx/SYNC_STAGES
add wave -noupdate -expand -group {UART RX FIFO} /wb_uart_tb/dut/rx_fifo/clk
add wave -noupdate -expand -group {UART RX FIFO} /wb_uart_tb/dut/rx_fifo/DATA_WIDTH
add wave -noupdate -expand -group {UART RX FIFO} /wb_uart_tb/dut/rx_fifo/DEPTH_WIDTH
add wave -noupdate -expand -group {UART RX FIFO} /wb_uart_tb/dut/rx_fifo/din
add wave -noupdate -expand -group {UART RX FIFO} /wb_uart_tb/dut/rx_fifo/dout
add wave -noupdate -expand -group {UART RX FIFO} /wb_uart_tb/dut/rx_fifo/empty
add wave -noupdate -expand -group {UART RX FIFO} /wb_uart_tb/dut/rx_fifo/fifo_dout
add wave -noupdate -expand -group {UART RX FIFO} /wb_uart_tb/dut/rx_fifo/fifo_empty
add wave -noupdate -expand -group {UART RX FIFO} /wb_uart_tb/dut/rx_fifo/fifo_rd_en
add wave -noupdate -expand -group {UART RX FIFO} /wb_uart_tb/dut/rx_fifo/full
add wave -noupdate -expand -group {UART RX FIFO} /wb_uart_tb/dut/rx_fifo/rd_en
add wave -noupdate -expand -group {UART RX FIFO} /wb_uart_tb/dut/rx_fifo/rst
add wave -noupdate -expand -group {UART RX FIFO} /wb_uart_tb/dut/rx_fifo/wr_en
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {5766226122 ps} 0} {{Cursor 2} {3719402 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {14679 ns}
