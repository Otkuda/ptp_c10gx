#ifndef _TSS_DRV_
#define _TSS_DRV_

#include "regs.h"
#include "print.h"

typedef struct tssParams {
    uint32_t sliceLength;
    uint32_t frameLength;
    uint32_t batchLength;
    uint32_t sequenceLength;
    uint32_t batchInterval;
    uint32_t lastFrame;
    uint32_t control;
    uint32_t userDeltaTime;
} tssParams;


void sendCommand(tssParams *params);
void getParams(tssParams *params);

#endif