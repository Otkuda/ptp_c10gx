#include "arith.h"
#include "ptp_drv.h"

void normalize_time(timestamp *ts) {
	ts->sec_l += ts->nsec / 1000000000;
	ts->nsec -= (ts->nsec / 1000000000) * 1000000000;
	if (ts->sec_l > 0 && ts->nsec < 0) {
		ts->sec_l -= 1;
		ts->nsec += 1000000000;
	} else if (ts->sec_l < 0 && ts->nsec > 0) {
		ts->sec_l += 1;
		ts->nsec -= 1000000000;
	}
}

void addTime(timestamp *r, timestamp *x, timestamp *y) {
	r->sec_l = x->sec_l + y->sec_l;
	r->nsec = x->nsec + y->nsec;
	normalize_time(r);
}

void subTime(timestamp *r, timestamp *x, timestamp *y) {
	r->sec_l = x->sec_l - y->sec_l;
	r->nsec = x->nsec - y->nsec;
	normalize_time(r);
}

void div2Time(timestamp *r) {
	r->nsec += (r->sec_l % 2) * 1000000000;
	r->sec_l >>= 1;
	r->nsec >>= 1;
	normalize_time(r);
}