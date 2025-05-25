/*
 *
 * PicoRV StepFPGA demo fw
 *
 * btko - Aug'22
 */
#include "main.h"
#include "irq.h"
#include "print.h"

extern void delay_1s();

char greet[] = "\n\r\n\r__RiscV PicoRV__\n\rCyclone10GX\n\r";

uint32_t val = 0;
uint8_t timer_enabled = 0;

void timer_handler(void) {
	leds = val++;
	if (val == 0x0100) val = 0;
	set_timer(_FREQ_);
}

void irq_20_handler(void) {
	switch(buttons) {
		case 1:
			print_str("0");
			break;
		case 2:
			print_str("1");
			break;
		case 4:
			print_str("2");
			break;
		default:
			break;
	}
	buttons = 0;
}

void menu() {
	print_str(greet);
}

void ptp_init() {
	RTC_PERIOD_H = RTC_SET_PERIOD_H;
	RTC_PERIOD_L = RTC_SET_PERIOD_L;
	RTC_CTRL = RTC_SET_CTRL_0;
	RTC_CTRL = RTC_SET_PERIOD;
	RTC_CTRL = RTC_SET_CTRL_0;
	print_str("RTC set\n");
	TSU_RXQUE_STATUS = TSU_MASK_RXMSGID
	TSU_TXQUE_STATUS = TSU_MASK_TXMSGID
	TSU_RXCTRL = TSU_SET_CTRL_0
	TSU_RXCTRL = TSU_SET_RXRST
	TSU_TXCTRL = TSU_SET_CTRL_0
	TSU_TXCTRL = TSU_SET_TXRST
}

void synchronize() {
	// prototype w/o verifying on test project
	TSU_RXCTRL = TSU_GET_RXQUE
	TSU_RXCTRL = TSU_SET_CTRL_0
	// now data from ptp packet is in regs
	uint32_t ptp_info = TSU_TXQUE_DATA_LL
	print_hex(ptp_info, 32) 
}

/*
 * main ===============================================================================
 */
int main() {
	uint8_t rx_temp;
	
	// uart setup
	uart_div = UART_DIV_VALUE;
	irq_unmask_one_bit(IRQ20_BUTTONS);	// enable IRQ20 (buttons)
	menu();		// usage menu
	RTC_CTRL = RTC_SET_RESET;
	RTC_CTRL = RTC_SET_CTRL_0;
	while (1) {
		// UART check
		if ((rx_temp = uart_rx) != 0xff) {
			switch (rx_temp) {
				case 't':
					if (timer_enabled) {
						print_str("disabling timer irq\n\r");
						irq_mask_one_bit(IRQ0_TIMER);
					} else {
						print_str("enabling timer irq\n\r");
						irq_unmask_one_bit(IRQ0_TIMER);
						set_timer(_FREQ_);
					}
					timer_enabled = !timer_enabled;
					break;
					
				case 'a':
				case ' ':
					menu();
					break;
					
				case 'i':
					ptp_init();
					break;

				default:
					uart_tx = rx_temp;	// echo
					segment1 = rx_temp & 0x0F;
					segment2 = (rx_temp >> 4) & 0x0f; 
					break;
			}
		}
		if (TSU_RXQUE_STATUS & 0x00FFFFFF > 0) {
			synchronize()
		}
	}
	return 0;
}


