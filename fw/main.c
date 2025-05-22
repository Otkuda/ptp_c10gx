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

char greet[] = "\n\r\n\r__RiscV StepFPGA__\n\rMax10 10M08SAM153C8G\n\r";

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
	RTC_PERIOD_H = 8;
	RTC_PERIOD_L = 0;
	RTC_CTRL = 0;
	RTC_CTRL = RTC_SET_PERIOD;
	RTC_CTRL = 0;
	print_str("ptp initd");
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
					
				case 'r':
					rgb1 = RGB_RED;
					rgb2 = RGB_RED;
					break;
					
				case 'g':
					rgb1 = RGB_GREEN;
					rgb2 = RGB_GREEN;
					break;
					
				case 'b':
					rgb1 = RGB_BLUE;
					rgb2 = RGB_BLUE;
					break;

				case 'o':
					rgb1 = RGB_OFF;
					rgb2 = RGB_OFF;
					break;
					
				case 's':
					print_str("switch: ");
					print_hex(sw, 2);
					print_str("\n\r");
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

	}
	return 0;
}


