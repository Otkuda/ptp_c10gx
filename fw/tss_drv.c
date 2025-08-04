#include "print.h"
#include "regs.h"
#include "tss_drv.h"

void getParams(tssParams *params) {
    char buf[12];
    printStr("input slice length: ");
    getStr(buf);
    params->sliceLength = atoi(buf);
    printStr("input frame length: ");
    getStr(buf);
    params->frameLength = atoi(buf);
    printStr("input batch length: ");
    getStr(buf);
    params->batchLength = atoi(buf);
    printStr("input seq length: ");
    getStr(buf);
    params->sequenceLength = atoi(buf);
    printStr("input batch interval: ");
    getStr(buf);
    params->batchInterval = atoi(buf);
    printStr("input last frame: ");
    getStr(buf);
    params->lastFrame = atoi(buf);
    printStr("input user delta time: ");
    getStr(buf);
    params->userDeltaTime = atoi(buf);
    printStr("input control: ");
    getStr(buf);
    params->control = atoi(buf);
}

void sendCommand(tssParams *params) {
    TSS_SLICE_LEN = params->sliceLength;
    TSS_FRAME_LEN = params->frameLength;
    TSS_BATCH_LEN = params->batchLength;
    TSS_SEQ_LEN = params->sequenceLength;
    TSS_BATCH_INTV = params->batchInterval;
    TSS_LAST_FRAME = params->lastFrame;
    TSS_CTRL = params->control;
    if (params->userDeltaTime != 0) TSS_USER_DELTA_TIME = params->userDeltaTime;
}