/*
 *
 * PTP slave implementation 
 *
 * Kirill Kotov
 * kirill.kotov@spbpu.com
 */
#include "regs.h"
#include "irq.h"
#include "print.h"
#include "arith.h"
#include "ptp_drv.h"


extern void delay_1s();

char greet[] = "\n\r_Cyclone10GX_ x\n\r";

void menu() {
	printStr(greet);
}

timestamp ts1, ts2, ts3, ts4;
timestamp delay, offset, localTime;
uint16_t seq_id, sync_seq_id;

ptpMsg message;

void handleMsg() {

	readMsgRx(&message);
	switch (message.msg_id) {
	case SYNC:
		handleSync(&message, &ts2);
		printTimestamp(&ts2);
		break;
	case FOLLOW_UP:
		handleFollowUp(&message, &ts1); // get time
		//printTimestamp(&ts1);
		getLocalTime(&localTime);
		updateOffset(&ts1, &ts2, &delay, &offset);
		printTimestamp(&offset);
		issueDelayReq(&message, &ts3);
		//printTimestamp(&ts3);
		break;
	case DELAY_RESP:
		handleDelayResp(&message, &ts4);
		//printTimestamp(&ts4);
		updateDelay(&ts1, &ts2, &ts3, &ts4, &delay);
		if (offset.sec_l != 0) setTime(&offset, &localTime);
		else applyOffset(&offset);
		printTimestamp(&localTime);
		break;
	default:
		break;
	}
}



/*
 * main ===============================================================================
 */
int main() {
	uint8_t rx_temp;

	// uart setup
	uart_div = UART_DIV_VALUE;
	menu();		// usage menu
	// RTC_CTRL = RTC_SET_RESET;
	// RTC_CTRL = RTC_SET_CTRL_0;
	while (1) {
		// UART check
		if ((rx_temp = uart_rx) != 0xff) {
			switch (rx_temp) {
					
				case 'a':
				case ' ':
					menu();
					break;
					
				case 'i':
					ptpInit();
					break;
				
				case 's': // get local time
					getLocalTime(&localTime);
					printTimestamp(&localTime);
					break;

				default:
					uart_tx = rx_temp;	// echos
					break;
			}
		}
		if (TSU_RXQUE_STATUS & 0x00FFFFFF > 0) {
			handleMsg();
		}
	}
	return 0;
}


