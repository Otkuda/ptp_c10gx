#ifndef _PTP_DRV_
#define _PTP_DRV_

#include <stdint.h>
#include "print.h"
#include "regs.h"

typedef struct ts {
    int32_t sec_l;
    int32_t nsec; 
} timestamp;

typedef struct {
    // info about PTP packet
    uint16_t seq_id;
    uint16_t  msg_id; // used only last 4 bits
    // timestamped time
    timestamp recvTime;
    // origin timestamp field
    timestamp originTimestamp;
} ptpMsg;

void ptpInit();
void getRxTimestamp(timestamp *ts);
void getTxTimestamp(timestamp *ts);
void getOriginTimestamp(timestamp *ts);
void getLocalTime(timestamp *ts);
void setOffset(timestamp *ts);
void setLocalTime(timestamp *ts);
void printTimestamp(timestamp *ts);
void readMsgRx(ptpMsg *msg);

#endif