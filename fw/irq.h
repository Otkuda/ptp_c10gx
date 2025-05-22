// irq.h

#ifndef IRQ_H
#define IRQ_H

#include <stdint.h>


#define IRQ0_TIMER		0
#define IRQ20_BUTTONS	20
#define IRQ21			21


uint32_t *irq(uint32_t *regs, uint32_t irqs);


void irq_unmask_one_bit(uint32_t irq);
void irq_mask_one_bit(uint32_t irq);


uint32_t set_timer(uint32_t timer_val);

#endif