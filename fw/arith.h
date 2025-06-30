#ifndef _ARITH_
#define _ARITH_

#include "ptp_drv.h"

void normalizeTime(timestamp *ts);
void addTime(timestamp *r, timestamp *x, timestamp *y);
void subTime(timestamp *r, timestamp *x, timestamp *y);
void div2Time(timestamp *r);

#endif