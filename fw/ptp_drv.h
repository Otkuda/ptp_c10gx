#ifndef _PTP_DRV_
#define _PTP_DRV_

#include <stdint.h>
#include "print.h"
#include "regs.h"
#include "arith.h"

typedef struct ts {
    int32_t sec_l;
    int32_t nsec; 
} timestamp;

typedef struct {
    // timestamped time
    timestamp recvTime;
    // origin timestamp field
    timestamp originTimestamp;
    // info about PTP packet
    uint16_t seq_id;
    uint16_t msg_id; // used only last 4 bits
    uint16_t sync_seq_id;
} ptpMsg;

typedef struct {
    /* data */
} ptpSeq;


void ptpInit();
void getRxTimestamp(timestamp *ts);
void getTxTimestamp(timestamp *ts);
void getOriginTimestamp(timestamp *ts);
void getLocalTime(timestamp *ts);
void setOffset(timestamp *ts);
void setLocalTime(timestamp *ts);
void printTimestamp(timestamp *ts);
void readMsgRx(ptpMsg *msg);
void issueDelayReq(ptpMsg *msg, timestamp *ts);
void handleSync(ptpMsg *msg, timestamp *ts);
void handleFollowUp(ptpMsg *msg, timestamp *ts);
void handleDelayResp(ptpMsg *msg, timestamp *ts);
void applyOffset(timestamp *offset, timestamp *localTime);
void updateOffset(timestamp *ts1, timestamp *ts2, timestamp *delay, timestamp *offset);
void updateDelay(timestamp *ts1, timestamp *ts2, timestamp *ts3, timestamp *ts4, timestamp *delay);

#endif