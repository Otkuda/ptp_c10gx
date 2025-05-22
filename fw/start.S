/* reference from gowin start.s */
#include "custom_ops.S"

	.section .init
	.global irq
	.global main

	.equ RGB_GREEN, 5
	.equ RGB_RED, 6
	.equ RGB_BLUE, 3
	
reset_vec:
	# no more than 16 bytes here !
	j start


/*******************  Interrupt handler **********************************/

.balign 8
irq_vec:
	# save registers 
	picorv32_setq_insn(q2, x1)
	picorv32_setq_insn(q3, x2)

	addi x1, x2, -128
	
	
	picorv32_getq_insn(x2, q0)		# store x2
	sw x2,   0*4(x1)
	picorv32_getq_insn(x2, q2)
	sw x2,   1*4(x1)
	picorv32_getq_insn(x2, q3)
	sw x2,   2*4(x1)

mv x2, x1

	sw x3,   3*4(x1)
	sw x4,   4*4(x1)
	sw x5,   5*4(x1)
	sw x6,   6*4(x1)
	sw x7,   7*4(x1)
	sw x8,   8*4(x1)
	sw x9,   9*4(x1)
	sw x10, 10*4(x1)
	sw x11, 11*4(x1)
	sw x12, 12*4(x1)
	sw x13, 13*4(x1)
	sw x14, 14*4(x1)
	sw x15, 15*4(x1)
	sw x16, 16*4(x1)
	sw x17, 17*4(x1)
	sw x18, 18*4(x1)
	sw x19, 19*4(x1)
	sw x20, 20*4(x1)
	sw x21, 21*4(x1)
	sw x22, 22*4(x1)
	sw x23, 23*4(x1)
	sw x24, 24*4(x1)
	sw x25, 25*4(x1)
	sw x26, 26*4(x1)
	sw x27, 27*4(x1)
	sw x28, 28*4(x1)
	sw x29, 29*4(x1)
	sw x30, 30*4(x1)
	sw x31, 31*4(x1)



	# call interrupt handler C function 

	# arg0 = address of regs
	mv a0, x1

	# arg1 = interrupt type
	picorv32_getq_insn(a1, q1)

	# call to C function
	jal ra, irq

	# restore registers
	# new irq_regs address returned from C code in a0
	#addi x1, a0, 0
addi x1, x2, 0

	lw x2,   0*4(x1)
	picorv32_setq_insn(q0, x2)

	lw x2,   1*4(x1)
	picorv32_setq_insn(q1, x2)

	lw x2,   2*4(x1)
	picorv32_setq_insn(q2, x2)


	lw x3,   3*4(x1)
	lw x4,   4*4(x1)
	lw x5,   5*4(x1)
	lw x6,   6*4(x1)
	lw x7,   7*4(x1)
	lw x8,   8*4(x1)
	lw x9,   9*4(x1)
	lw x10, 10*4(x1)
	lw x11, 11*4(x1)
	lw x12, 12*4(x1)
	lw x13, 13*4(x1)
	lw x14, 14*4(x1)
	lw x15, 15*4(x1)
	lw x16, 16*4(x1)
	lw x17, 17*4(x1)
	lw x18, 18*4(x1)
	lw x19, 19*4(x1)
	lw x20, 20*4(x1)
	lw x21, 21*4(x1)
	lw x22, 22*4(x1)
	lw x23, 23*4(x1)
	lw x24, 24*4(x1)
	lw x25, 25*4(x1)
	lw x26, 26*4(x1)
	lw x27, 27*4(x1)
	lw x28, 28*4(x1)
	lw x29, 29*4(x1)
	lw x30, 30*4(x1)
	lw x31, 31*4(x1)

	picorv32_getq_insn(x1, q1)
	picorv32_getq_insn(x2, q2)
	picorv32_retirq_insn()


	.global start
	.type start,@function
	
	
/* Main program  **********************************/
start:
	/* zero-initialize all registers */

	addi x1, zero, 0
	li x2, 0x1400		# stack pointer update
	addi x3, zero, 0
	addi x4, zero, 0
	addi x5, zero, 0
	addi x6, zero, 0
	addi x7, zero, 0
	addi x8, zero, 0
	addi x9, zero, 0
	addi x10, zero, 0
	addi x11, zero, 0
	addi x12, zero, 0
	addi x13, zero, 0
	addi x14, zero, 0
	addi x15, zero, 0
	addi x16, zero, 0
	addi x17, zero, 0
	addi x18, zero, 0
	addi x19, zero, 0
	addi x20, zero, 0
	addi x21, zero, 0
	addi x22, zero, 0
	addi x23, zero, 0
	addi x24, zero, 0
	addi x25, zero, 0
	addi x26, zero, 0
	addi x27, zero, 0
	addi x28, zero, 0
	addi x29, zero, 0
	addi x30, zero, 0
	addi x31, zero, 0

	# initialize control and status registers
	#csrw mepc,		zero
	#csrw mcause,	zero
	#csrw mscratch,	zero
	#csrw mtval,		zero


	#copy -data- section to ram
	#la a0, _sidata		# from end of .text
	lui a4, %hi(_sidata)
	addi a4,a4, %lo(_sidata)
	la a1, _sdata		# start of data section
	la a2, _edata		# end
	bge a1, a2, end_init_data
loop_init_data:
	lw a3, 0(a4)	# get data from .text
	sw a3, 0(a1)	# store in data ram
	addi a4, a4, 4
	addi a1, a1, 4	# inc
	blt a1, a2, loop_init_data
end_init_data:

	#zero -bss- section
	la a0, _sbss
	la a1, _ebss
	bge a0, a1, end_init_bss
loop_init_bss:
	sw zero, 0(a0)
	addi a0,a0,4
	blt a0, a1, loop_init_bss
end_init_bss:

	
	# debug green before main
	#li a0, RGB_GREEN
	# call update_rgb

	call main
	
	# debug red on return
	#li a0, RGB_RED
	#call update_rgb

loop:
	j loop

update_rgb:
	# a5 = address
	lui a5, %hi(0x02003000)
	addi a5, a5, 0
	
	# write a0 => 0x02003000
	sb a0, 0(a5)
	ret

	
	.global delay_1s
	.type delay_1s,@function
delay_1s:	# approximated 1 sec delay
	addi sp,sp,-32
	sw s0,28(sp)
	addi s0,sp,32
	li a5,5555555	
dis_loop:			# https://github.com/YosysHQ/picorv32#cycles-per-instruction-performance
	addi a5,a5,-1		#-->  3 cycles
	bnez a5, dis_loop	#-->  6 cycles
	# 9 cycles per instruction @ 50MHz clock => 50_000_000 / 9 => 5555555 (approx)
	lw s0,28(sp)
	addi sp,sp,32
	ret