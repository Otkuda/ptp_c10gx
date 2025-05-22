#ifndef __MAIN_H__
#define __MAIN_H__

#include <stdint.h>


// 8-bit leds
#define leds 	(* (volatile uint32_t *) 	0x02000000)

// 7-segment display
#define segment1 (* (volatile uint32_t *) 	0x02002000)	
#define segment2 (* (volatile uint32_t *) 	0x02002004)	
#define segment_disable = 0x00000020

// 2x RGB leds
#define rgb1	(* (volatile uint32_t *) 	0x02003000)
#define rgb2	(* (volatile uint32_t *) 	0x02003004)
#define RGB_RED 	6
#define RGB_GREEN	5
#define RGB_BLUE	3
#define RGB_OFF		7

// UART
#define uart_div	(* (volatile uint32_t *) 	0x02004008)
#define uart_rx		(* (volatile uint32_t *) 	0x02004000)
#define uart_tx		(* (volatile uint32_t *) 	0x02004000)

// button
#define buttons		(* (volatile uint32_t *) 	0x02005000)

// switch
#define sw 			(* (volatile uint32_t *) 	0x02008000)

/* -- not used --
#define spimem (* (volatile uint32_t *) 	0x00100000)
#define spimemcfg (* (volatile uint32_t *) 	0x00111111)
#define ram 	(* (volatile uint32_t *) 0x00004000)
*/

// PTP
#define RTC_CTRL       (* (volatile uint32_t *) 0x03000000)
#define RTC_TIME_SEC_H (* (volatile uint32_t *) 0x03000010)
#define RTC_TIME_SEC_L (* (volatile uint32_t *) 0x03000014)
#define RTC_TIME_NSC_H (* (volatile uint32_t *) 0x03000018)
#define RTC_TIME_NSC_L (* (volatile uint32_t *) 0x0300001C)
#define RTC_PERIOD_H   (* (volatile uint32_t *) 0x03000020)
#define RTC_PERIOD_L   (* (volatile uint32_t *) 0x03000024)
#define RTC_ADJPER_H   (* (volatile uint32_t *) 0x03000028)
#define RTC_ADJPER_L   (* (volatile uint32_t *) 0x0300002C)
#define RTC_ADJNUM     (* (volatile uint32_t *) 0x03000030)
// define RTC control values
#define RTC_SET_CTRL_0 0x00
#define RTC_GET_TIME   0x01
#define RTC_SET_ADJ    0x02
#define RTC_SET_PERIOD 0x04
#define RTC_SET_TIME   0x08
#define RTC_SET_RESET  0x10
// define RTC data values
#define RTC_SET_PERIOD_H 0x8     // 8ns for 125MHz rtc_clk
#define RTC_SET_PERIOD_L 0x0
// define RTC constant
#define RTC_ACCMOD_H 0x3B9ACA00  // 1,000,000,000 for 30bit
#define RTC_ACCMOD_L 0x0         // 256 for 8bit

// define TSU address values
#define TSU_RXCTRL        (* (volatile uint32_t *) 0x00000040)
#define TSU_RXQUE_STATUS  (* (volatile uint32_t *) 0x00000044)
#define TSU_RXQUE_DATA_HH (* (volatile uint32_t *) 0x00000050)
#define TSU_RXQUE_DATA_HL (* (volatile uint32_t *) 0x00000054)
#define TSU_RXQUE_DATA_LH (* (volatile uint32_t *) 0x00000058)
#define TSU_RXQUE_DATA_LL (* (volatile uint32_t *) 0x0000005C)
#define TSU_TXCTRL        (* (volatile uint32_t *) 0x00000060)
#define TSU_TXQUE_STATUS  (* (volatile uint32_t *) 0x00000064)
#define TSU_TXQUE_DATA_HH (* (volatile uint32_t *) 0x00000070)
#define TSU_TXQUE_DATA_HL (* (volatile uint32_t *) 0x00000074)
#define TSU_TXQUE_DATA_LH (* (volatile uint32_t *) 0x00000078)
#define TSU_TXQUE_DATA_LL (* (volatile uint32_t *) 0x0000007C)
// define TSU control values
#define TSU_SET_CTRL_0  0x00
#define TSU_GET_RXQUE   0x01
#define TSU_SET_RXRST   0x02
#define TSU_GET_TXQUE   0x01
#define TSU_SET_TXRST   0x02
// define TSU data values
#define TSU_MASK_RXMSGID 0xFF000000  // FF to enable 0x0 to 0x7
#define TSU_MASK_TXMSGID 0xFF000000  // FF to enable 0x0 to 0x7

#define _FREQ_ 125000000		// 50 MHz clock
#define _BAUD_ 115200
#define UART_DIV_VALUE (int) (_FREQ_/_BAUD_) - 1	// baud = clk_freq / (divisor + 1)

#endif //__MAIN_H__