// source -> Gowin PicoRV32 files

// #include "firmware.h"
#include "irq.h"


/* Variables --------------------------------------------------------------------- */
uint32_t irq_mask = 0xffffffff;   //a global variable to save irq mask values.


/* Functions --------------------------------------------------------------------- */
void default_irq_handler(void) {
	// printf("Default interrupt handler\n");
}

/* Interrupt Handler */
//System Interrupt Handler
void timer_handler(void) __attribute__((weak, alias("default_irq_handler")));//0: timer interrupt
//void irq_1_handler(void) __attribute__((weak, alias("default_irq_handler")));//1: debug breakpoint interrupt
//void irq_2_handler(void) __attribute__((weak, alias("default_irq_handler")));//2: bus error interrupt
//void irq_3_handler(void) __attribute__((weak, alias("default_irq_handler")));//3: illegal instruction interrupt
//void irq_4_handler(void) __attribute__((weak, alias("default_irq_handler")));//4: debug interrupt
//void irq_5_handler(void) __attribute__((weak, alias("default_irq_handler")));//5: hardware stack protection interrupt

//Peripherals Interrupt Handler
//void irq_10_handler(void) __attribute__((weak, alias("default_irq_handler")));//10: Wishbone SPI Master Interrupt Handler
//void irq_11_handler(void) __attribute__((weak, alias("default_irq_handler")));//11: Wishbone SPI Slave Interrupt Handler
//void irq_12_handler(void) __attribute__((weak, alias("default_irq_handler")));//12: Wishbone I2C Master Interrupt Handler

//External User Interrupt Handler
//For Open Wishbone Interface and Open AHB Interface Interrupt Handler
//20~31
void irq_20_handler(void) __attribute__((weak, alias("default_irq_handler")));//20:
void irq_21_handler(void) __attribute__((weak, alias("default_irq_handler")));//21:
//...																		  //22~31:


void mask_irq(uint32_t mask) {
	__asm__ __volatile__("mv a4, a0");
	__asm__ __volatile__(".word(0x0607678b)");
	return;
}

void irq_mask_one_bit(uint32_t irq) {
	irq_mask = irq_mask | (1 << irq);
	mask_irq(irq_mask);
}

void irq_unmask_one_bit(uint32_t irq) {
	irq_mask = irq_mask & (~(1 << irq));
	mask_irq(irq_mask);
}

uint32_t set_timer(uint32_t timer_val) {
	uint32_t old_val = 0;
	__asm__ __volatile__("mv a4, a0");
	__asm__ __volatile__(".word(0x0a07078b)");
	__asm__ __volatile__("mv %[dest], a5"  :[dest]"=r"(old_val));
	return old_val;
}

uint32_t *irq(uint32_t *regs, uint32_t irqs) {
	
	irq_mask = irq_mask | irqs;  //mask up the running interrupt
	mask_irq(irq_mask);

	if ((irqs & 1) != 0) {
		timer_handler();
	}

	if ((irqs & (1<<20)) != 0) {
		 irq_20_handler();		// button handler
	}

	if ((irqs & (1<<21)) != 0) {
		irq_21_handler();
	}

	
	irq_mask = irq_mask & (~irqs);  //unmask the finished interrupt
	mask_irq(irq_mask);

	return regs;
}







