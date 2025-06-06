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

char greet[] = "\n\r_Cyclone10GX_\n\r";

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

void get_tsed_time_rx(timestamp *ts) {
	ts->sec_l = TSU_RXQUE_DATA_HL;
	ts->nsec = TSU_RXQUE_DATA_LH;
}

void get_tsed_time_tx(timestamp *ts) {
	ts->sec_l = TSU_TXQUE_DATA_HL;
	ts->nsec = TSU_TXQUE_DATA_LH;
}

void get_time_msg(timestamp *ts) {
	ts->sec_l = TSU_RXQUE_TS_SECL;
	ts->nsec  = TSU_RXQUE_TS_NSEC;
}

void get_local_time(timestamp *ts) {
	RTC_CTRL = RTC_GET_TIME;
	ts->sec_l = RTC_TIME_SEC_L;
	ts->nsec = RTC_TIME_NSC_H;
	RTC_CTRL = RTC_SET_CTRL_0;
}

void set_offset(timestamp *ts) {
	RTC_ADJPER_L = ts->nsec;
	RTC_ADJNUM = 1;

}

void set_local_time(timestamp *ts) {
	RTC_TIME_SEC_L = ts->sec_l;
	RTC_TIME_NSC_H = ts->nsec;
	RTC_CTRL = RTC_SET_TIME;
	RTC_CTRL = RTC_GET_TIME;
	RTC_CTRL = RTC_SET_CTRL_0;
}

void normalize_time(timestamp *ts) {
	ts->sec_l += ts->nsec / 1000000000;
	ts->nsec -= (ts->nsec / 1000000000) * 1000000000;
	if (ts->sec_l > 0 && ts->nsec < 0) {
		ts->sec_l -= 1;
		ts->nsec += 1000000000;
	} else if (ts->sec_l < 0 && ts->nsec > 0) {
		ts->sec_l += 1;
		ts->nsec -= 1000000000;
	}
}

void addTime(timestamp *r, timestamp *x, timestamp *y) {
	r->sec_l = x->sec_l + y->sec_l;
	r->nsec = x->nsec + y->nsec;
	normalize_time(r);
}

void subTime(timestamp *r, timestamp *x, timestamp *y) {
	r->sec_l = x->sec_l - y->sec_l;
	r->nsec = x->nsec - y->nsec;
	normalize_time(r);
}

void div2Time(timestamp *r) {
	r->nsec += (r->sec_l % 2) * 1000000000;
	r->sec_l >>= 1;
	r->nsec >>= 1;
	normalize_time(r);
}

void printTimestamp(timestamp *ts) {
	print_hex(ts->sec_l, 8);
	print_hex(ts->nsec, 8);
	print_str("\n\r");
}

uint16_t seq_id, sync_seq_id;
uint8_t step;
uint8_t update_rtt = 1;
timestamp ts1, ts2, ts3, ts4;
timestamp rtt, offset, rtc;

void synchronize() {
	uint32_t ptp_info;
	uint8_t msg_id;

	// prototype w/o verifying on test project
	TSU_RXCTRL = TSU_GET_RXQUE;
	TSU_RXCTRL = TSU_SET_CTRL_0;
	// now data from ptp packet is in regs
	// get sync recv time into ts2
	// get data from registers
	ptp_info = TSU_RXQUE_DATA_LL;
	msg_id = ptp_info >> 28;
	seq_id = ptp_info & 0x0000ffff;
	// now we have sync msg -> can get t2
	// then we have to wait for follow up
	if (msg_id != 0) return; // synchronization starts with sync
	get_tsed_time_rx(&ts2);
	step = FOLLOW_UP;
	sync_seq_id = seq_id;
	while (step != SYNC) {
		switch (step) {
			case FOLLOW_UP:
				if (TSU_RXQUE_STATUS & 0x00ffffff > 0) {
					TSU_RXCTRL = TSU_GET_RXQUE;
					TSU_RXCTRL = TSU_SET_CTRL_0;
					ptp_info = TSU_RXQUE_DATA_LL;
					msg_id = ptp_info >> 28;
					seq_id = ptp_info & 0x0000ffff;
					if (msg_id != FOLLOW_UP || seq_id != sync_seq_id) step = SYNC;
					else {
						get_time_msg(&ts1);
						step = DELAY_REQ;
						subTime(&ts2, &ts2, &ts1);
					}
				} else {
					continue;
				}
				break;
			
			case DELAY_REQ:
				RTC_CTRL = RTC_GET_TIME;
				PTP_GEN_INFO = 0x10000000 | sync_seq_id;
				PTP_GEN_TSSL = RTC_TIME_SEC_L;
				PTP_GEN_TSNS = RTC_TIME_NSC_H;
				PTP_GEN_CTRL = 1;
				TSU_TXCTRL = TSU_GET_TXQUE;
				TSU_TXCTRL = TSU_SET_CTRL_0;
				get_tsed_time_tx(&ts3);
				step = DELAY_RESP;
				RTC_CTRL = RTC_SET_CTRL_0;
				break;
			
			case DELAY_RESP:
				if (TSU_RXQUE_STATUS & 0x00ffffff > 0) {
					TSU_RXCTRL = TSU_GET_RXQUE;
					TSU_RXCTRL = TSU_SET_CTRL_0;
					ptp_info = TSU_RXQUE_DATA_LL;
					msg_id = ptp_info >> 28;
					seq_id = ptp_info & 0x0000ffff;
					if (msg_id != DELAY_RESP || seq_id != sync_seq_id) step = SYNC;
					else {
						get_time_msg(&ts4);
						step = SYNC;
					}
				} else {
					continue;
				}
				break;

			default:
				break;
		}
	}
	
	subTime(&ts4, &ts4, &ts3);
	addTime(&rtt, &ts2, &ts4);
	div2Time(&rtt);
	printTimestamp(&rtt);

	subTime(&ts2, &ts2, &rtt);
	subTime(&offset, &offset, &ts2);
	get_local_time(&rtc);
	subTime(&rtc, &rtc, &ts2);
	set_local_time(&rtc);
	printTimestamp(&rtc);
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
				
				// case 's':
				// 	send_ptp();
				// 	break;

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


