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
	print_str("RTC set\n\r");
	TSU_RXQUE_STATUS = TSU_MASK_RXMSGID;
	TSU_TXQUE_STATUS = TSU_MASK_TXMSGID;
	TSU_RXCTRL = TSU_SET_CTRL_0;
	TSU_RXCTRL = TSU_SET_RXRST;
	TSU_TXCTRL = TSU_SET_CTRL_0;
	TSU_TXCTRL = TSU_SET_TXRST;
}

void get_local_time(timestamp *ts) {
	RTC_CTRL = RTC_GET_TIME;
	RTC_CTRL = RTC_SET_CTRL_0;
	ts->sec_h = RTC_TIME_SEC_H;
	ts->sec_l = RTC_TIME_SEC_L;
	ts->nsec = RTC_TIME_NSC_H;
}

void get_time_msg(timestamp *ts) {
	ts->sec_h = TSU_RXQUE_DATA_HH;
	ts->sec_l = TSU_RXQUE_DATA_HL;
	ts->nsec  = TSU_RXQUE_DATA_LH;
}

void synchronize() {
	uint32_t ptp_info;
	uint8_t msg_id;
	uint16_t seq_id;
	uint8_t step;
	timestamp ts1, ts2, ts3, ts4;

	// prototype w/o verifying on test project
	TSU_RXCTRL = TSU_GET_RXQUE;
	TSU_RXCTRL = TSU_SET_CTRL_0;
	// now data from ptp packet is in regs
	// get sync recv time into ts2
	get_local_time(&ts2);
	get_time_msg(&ts1);
	// get data from registers
	ptp_info = TSU_RXQUE_DATA_LL;
	msg_id = ptp_info >> 28;
	seq_id = ptp_info & 0x0000ffff;

	step = FOLLOW_UP;
	while (1) {
		while (TSU_RXQUE_STATUS & 0x00FFFFFF > 0)
		{
			TSU_RXCTRL = TSU_GET_RXQUE;
			TSU_RXCTRL = TSU_SET_CTRL_0;
			break;
		}
		ptp_info = TSU_RXQUE_DATA_LL;
		msg_id = ptp_info >> 28;
		seq_id = ptp_info & 0x0000ffff;
		// switch (msg_id) {
		// 	case 
		// }
		
	}
}

void send_ptp() {
	PTP_GEN_INFO = 0x11235555;
	PTP_GEN_TSSL = 0x123;
	PTP_GEN_CTRL = 0x01;
	print_str("ptp_sent");
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
				
				case 's':
					send_ptp();
					break;

				case 'g':
					time_s = get_time();
					print_hex(time_s, 8);
					break;
				default:
					uart_tx = rx_temp;	// echos
					break;
			}
		}
		if (TSU_RXQUE_STATUS & 0x00FFFFFF > 0) {
			synchronize();
		}
	}
	return 0;
}


