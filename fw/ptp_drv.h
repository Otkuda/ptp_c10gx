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


#endif