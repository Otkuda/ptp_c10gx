#ifndef _ARITH_
#define _ARITH

#include "ptp_drv.h"

void normalize_time(timestamp *ts);
void addTime(timestamp *r, timestamp *x, timestamp *y);
void subTime(timestamp *r, timestamp *x, timestamp *y);
void div2Time(timestamp *r);

#endif