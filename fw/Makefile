# riscv compilation makefile

PROJECT_NAME	:= PicoRVStepFPGA

ifdef OS
	RM = @del
	CROSS_COMPILE:=riscv32-unknown-elf-
	QUARTUS_DIR = \intelFPGA_lite\18.1\quartus\bin64
	TOOLS_DIR=tools\\
	PYTHON = python
else
#else ifeq ($(shell uname), Linux)
	RM = rm -f
	CROSS_COMPILE:=riscv32-unknown-elf-
	TOOLS_DIR=tools/
	PYTHON = python3
endif

ifeq ($(shell uname), MINGW32_NT-10.0-22000)
	RM = rm -f
endif

CC:=		$(CROSS_COMPILE)gcc
OBJCOPY:=	$(CROSS_COMPILE)objcopy
OBJDUMP:=	$(CROSS_COMPILE)objdump
SIZE:=		$(CROSS_COMPILE)size
TARGET:=	main
CCFLAGS:=	-march=rv32imd -Wl,-Bstatic,-T,sections.lds,--strip-debug -ffreestanding -nostdlib
ASFLAGS:=	-march=rv32imd  -Wa,-adhln -g -fno-asynchronous-unwind-tables 
DEPS:=		$(TARGET).c start.S irq.c print.c arith.c ptp_drv.c 
CLEANTARGET:= elf out bin lst mif o
B2MIF	:= $(TOOLS_DIR)bin2mif.py

#=== main =======================================
all: $(TARGET).mif

%.o: %.c
	$(CC) -march=rv32imd -ffreestanding -nostdlib -c $<

$(TARGET).mif : $(TARGET).bin
	$(PYTHON) $(B2MIF) $^ $@

$(TARGET).elf : $(DEPS)
	$(CC) $(CCFLAGS) -o $@ $^
	$(SIZE) $@


$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $^ $(TARGET).bin

#=== disassembly ===============================
$(TARGET).lst: $(TARGET).elf
	$(CC) $(ASFLAGS) -o $^ $(DEPS) > $@

disasm: $(TARGET).elf
	$(OBJDUMP) -D -S  $(TARGET).elf > disasm.lst

#== quartus util (not working) =================
update_ram: $(TARGET).mif
	cd ..
	$(QUARTUS_DIR)\quartus_cdb $(PROJECT_NAME)-c $(PROJECT_NAME)--update_mif
	$(QUARTUS_DIR)\quartus_asm --read_settings_files=on --write_settings_files=off $(PROJECT_NAME) -c $(PROJECT_NAME)
	
#=== utils =====================================
clean:
	$(foreach var, $(CLEANTARGET), $(RM) $(TARGET).$(var);)
	$(RM) $(TARGET)*.i $(TARGET)*.s $(TARGET)*.o
	$(RM) disasm.lst
	$(RM) *.o

help:
	@echo 1.  'make' to make $(TARGET).mif from deps: $(DEPS)
	@echo 2.  'make disasm' to disassemble $(TARGET).elf.  creates disasm.lst
	@echo 3.  x - 'make $(TARGET).lst' old disassembly option
	@echo 4.  x - 'make update_ram' work in prog to auto update mif file to quartus.  [not working]
	
.phony: clean all update_ram disasm help

