#include "ptp_drv.h"
#include "print.h"
#include "regs.h"

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
	RTC_ADJPER_L = -ts->nsec;
	RTC_ADJNUM = 1;

}

void set_local_time(timestamp *ts) {
	RTC_TIME_SEC_L = ts->sec_l;
	RTC_TIME_NSC_H = ts->nsec;
	RTC_CTRL = RTC_SET_TIME;
	RTC_CTRL = RTC_GET_TIME;
	RTC_CTRL = RTC_SET_CTRL_0;
}

void printTimestamp(timestamp *ts) {
	print_hex(ts->sec_l, 8);
	print_hex(ts->nsec, 8);
	print_str("\n\r");
}

void calculate_delay(timestamp *delay, timestamp *ts1, timestamp *ts2, timestamp *ts3, timestamp *ts4) {
	return;
}