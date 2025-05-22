# Wishbone UART
=======================

## Основной тест wb_uart:
### Test module:
    1. wb_uart_tb.sv
    2. run.tcl
    3. wave.do (do file to fill in waveform)
##### The main modules that have been synthesized together are:
    1. wb_uart.sv
    2. uart_receiver.sv
    3. uart_transmitter.sv
    4. wb_if.sv
    5. wb_if_defs.svh 
    6. fifo_fwft.v
    7. fifo.v
    8. fifo_fwft_adapter.v
    9. simple_dpram_sclk.v
##### Modules that were also used in testing: 
    1. wb_bfm_master.v 
    2. wb_bfm_master_wrp.sv 
    3. uart_model.sv 
    4. wb_common.v 
    5. wb_common_params.v

## Тестирование приемника и передатчика UART с использованием модели UART:
Проверка передачи данных uart_model --> uart_receiver.  
Проверка передачи данных uart_transmitter --> uart_model.  
Проверка обратной связь модуля uart_model.  
Проверка передачи данных uart_transmitter --> uart_receiver
### Test module:
    1. wb_rxtx_tb.sv
    2. run_uart_rxtx_tb.do
##### Main modules:
    1. uart_receiver.sv
    2. uart_transmitter.sv
##### Modules that were also used in testing:
    1. uart_model.sv

## Частный тест для проверки обратной связи модели UART:
### Test module:
    1. wb_model_tb.sv
    2. run_uart_model_tb.do 
##### Main modules:
    1. uart_model.sv
    