#include "print.h"
#include "regs.h"
#include "arith.h"
#include "ptp_drv.h"

void ptpInit() {
	RTC_PERIOD_H = RTC_SET_PERIOD_H;
	RTC_PERIOD_L = RTC_SET_PERIOD_L;
	RTC_CTRL = RTC_SET_CTRL_0;
	RTC_CTRL = RTC_SET_PERIOD;
	RTC_CTRL = RTC_SET_CTRL_0;
	printStr("RTC set\n\r");
	TSU_RXQUE_STATUS = TSU_MASK_RXMSGID;
	TSU_TXQUE_STATUS = TSU_MASK_TXMSGID;
	TSU_RXCTRL = TSU_SET_CTRL_0;
	TSU_RXCTRL = TSU_SET_RXRST;
	TSU_TXCTRL = TSU_SET_CTRL_0;
	TSU_TXCTRL = TSU_SET_TXRST;
}

void getRxTimestamp(timestamp *ts) {
	ts->sec_l = TSU_RXQUE_DATA_HL;
	ts->nsec = TSU_RXQUE_DATA_LH;
}

void getTxTimestamp(timestamp *ts) {
	ts->sec_l = TSU_TXQUE_DATA_HL;
	ts->nsec = TSU_TXQUE_DATA_LH;
}

void getOriginTimestamp(timestamp *ts) {
	ts->sec_l = TSU_RXQUE_TS_SECL;
	ts->nsec  = TSU_RXQUE_TS_NSEC;
}

void getLocalTime(timestamp *ts) {
	RTC_CTRL = RTC_GET_TIME;
	ts->sec_l = RTC_TIME_SEC_L;
	ts->nsec = RTC_TIME_NSC_H;
	RTC_CTRL = RTC_SET_CTRL_0;
}

void setOffset(timestamp *ts) {
	RTC_ADJPER_L = -ts->nsec;
	RTC_ADJNUM = 1;

}

void setLocalTime(timestamp *ts) {
	RTC_TIME_SEC_L = ts->sec_l;
	RTC_TIME_NSC_H = ts->nsec;
	RTC_CTRL = RTC_SET_TIME;
	RTC_CTRL = RTC_GET_TIME;
	RTC_CTRL = RTC_SET_CTRL_0;
}

void printTimestamp(timestamp *ts) {
	printHex(ts->sec_l, 8);
	printHex(ts->nsec, 8);
	printStr("\n\r");
}

void readMsgRx(ptpMsg *msg) {
	// get msg from fifo to registers
	TSU_RXCTRL = TSU_GET_RXQUE;
	TSU_RXCTRL = TSU_SET_CTRL_0;
	// get info to struct
	msg->seq_id = TSU_RXQUE_DATA_LL & 0xff;
	msg->msg_id = TSU_RXQUE_DATA_LL >> 28;

	getRxTimestamp(&(msg->recvTime));
	getOriginTimestamp(&(msg->originTimestamp));
}

void issueDelayReq(ptpMsg *msg, timestamp *ts) {
	PTP_GEN_INFO = 0x10000000 | msg->sync_seq_id;
	PTP_GEN_CTRL = 1;
	
	while (!(TSU_TXQUE_STATUS & 0x000000ff));
	TSU_TXCTRL = TSU_GET_TXQUE;
	TSU_TXCTRL = TSU_SET_CTRL_0;
	getTxTimestamp(ts);
}

void handleSync(ptpMsg *msg, timestamp *ts) {
	msg->sync_seq_id = msg->seq_id; // set sequence id for this synchronization sequence
	*ts = msg->recvTime; 
}

void handleFollowUp(ptpMsg *msg, timestamp *ts) {
	if (msg->sync_seq_id != msg->seq_id) return;
	else {
		*ts = msg->originTimestamp;
	}
}

void handleDelayResp(ptpMsg *msg, timestamp *ts) {
	if (msg->sync_seq_id != msg->seq_id) return;
	else {
		*ts = msg->originTimestamp;
	}
}

void setTime(timestamp *offset, timestamp *localTime) {
	getLocalTime(localTime);
	subTime(localTime, localTime, offset);
	normalizeTime(localTime);
	setLocalTime(localTime);
}

void applyOffset(timestamp *offset) {
	RTC_OFFSET -= offset->nsec;
	RTC_CTRL = 0x00100000;
	RTC_CTRL = RTC_SET_CTRL_0;
}

void updateOffset(timestamp *ts1, timestamp *ts2, timestamp *delay, timestamp *offset) {
	subTime(offset, ts2, ts1);
	normalizeTime(offset);
	subTime(offset, offset, delay); // offset(n)
	normalizeTime(offset);
}

void updateDelay(timestamp *ts1, timestamp *ts2, timestamp *ts3, timestamp *ts4, timestamp *delay) {
	subTime(ts2, ts2, ts1);
	subTime(ts4, ts4, ts3);
	normalizeTime(ts2);
	normalizeTime(ts4);
	addTime(delay, ts2, ts4);
	normalizeTime(delay);
	div2Time(delay);
}