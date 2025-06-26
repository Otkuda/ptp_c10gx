/*
 *
 * PicoRV StepFPGA demo fw
 *
 * btko - Aug'22
 */
#include "regs.h"
#include "irq.h"
#include "print.h"
#include "ptp_drv.h"
#include "arith.h"

extern void delay_1s();

char greet[] = "\n\r_Cyclone10GX_\n\r";

uint32_t val = 0;
uint8_t timer_enabled = 0;


void irq_20_handler(void) {
	switch(buttons) {
		case 1:
			printStr("0");
			break;
		case 2:
			printStr("1");
			break;
		case 4:
			printStr("2");
			break;
		default:
			break;
	}
	buttons = 0;
}

void menu() {
	printStr(greet);
}

uint16_t seq_id, sync_seq_id;
uint8_t step;
uint8_t update_rtt = 1;
timestamp ts1, ts2, ts3, ts4;
timestamp rtt, offset, rtc;

void handleMsg() {
	// read message info
	TSU_RXCTRL = TSU_GET_RXQUE;
	TSU_RXCTRL = TSU_SET_CTRL_0;
}


/*
 * main ===============================================================================
 */
int main() {
	uint8_t rx_temp;
	uint32_t time_s;

	// uart setup
	uart_div = UART_DIV_VALUE;
	irq_unmask_one_bit(IRQ20_BUTTONS);	// enable IRQ20 (buttons)
	menu();		// usage menu
	// RTC_CTRL = RTC_SET_RESET;
	// RTC_CTRL = RTC_SET_CTRL_0;
	while (1) {
		// UART check
		if ((rx_temp = uart_rx) != 0xff) {
			switch (rx_temp) {
				case 't':
					if (timer_enabled) {
						printStr("disabling timer irq\n\r");
						irq_mask_one_bit(IRQ0_TIMER);
					} else {
						printStr("enabling timer irq\n\r");
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
					ptpInit();
					break;
				
				case 's': // get local time
					getLocalTime(&rtc);
					printTimestamp(&rtc);
					break;

				default:
					uart_tx = rx_temp;	// echos
					break;
			}
		}
		if (TSU_RXQUE_STATUS & 0x00FFFFFF > 0) {
			msgHandle();
		}
	}
	return 0;
}


