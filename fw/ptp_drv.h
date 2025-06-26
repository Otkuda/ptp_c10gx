#ifndef _PTP_DRV_
#define _PTP_DRV_

#include <stdint.h>
#include "print.h"
#include "regs.h"

typedef struct ts {
    int32_t sec_l;
    int32_t nsec; 
} timestamp;

void ptp_init();
void get_tsed_time_rx(timestamp *ts);
void get_tsed_time_tx(timestamp *ts);
void get_time_msg(timestamp *ts);
void get_local_time(timestamp *ts);
void set_offset(timestamp *ts);
void set_local_time(timestamp *ts);
void printTimestamp(timestamp *ts);
void calculate_delay(timestamp *delay, timestamp *ts1, timestamp *ts2, timestamp *ts3, timestamp *ts4);
void calculate_offset(timestamp *ts1, timestamp *ts2, timestamp *delay);

#endif