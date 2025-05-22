#!/usr/bin/python3
'''
converts riscv binary file to mif format

'''
import sys, os
from math import ceil, log
from os.path import getsize

def get_next_block(size):
	return 2**ceil(log(size, 2))
	
	
def bytes_from_file(filename):
	with open(filename, 'rb') as f:
		while True:
			chunk = f.read(4)
			if chunk:
				yield chunk		
			else:
				break
	
if __name__ == "__main__":
	if len(sys.argv) < 2:
		print('v'*50)
		print('__RiscV binary to MIF converter__')
		print(f'usage:\n\t {sys.argv[0]} <infile.bin> <outfile.mif>')
		print('^'*50)
		sys.exit()
	infilename = sys.argv[1]
	outfilename = sys.argv[2]
	
	depth= get_next_block( getsize(infilename) * 8 / 32 )

	mif = open(outfilename, 'w')
	mif.write(f"DEPTH = {depth};\nWIDTH = 32;\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\n\nCONTENT\nBEGIN\n")

	addr=0
	startaddr=0
	prevvalue=0
	outstr = ""
	
	for b in bytes_from_file(infilename):
		#value = int.from_bytes(b, 'big')
		value = int.from_bytes(b, 'little')		# correct
		outstr = "\t{:X} : {:08X};\n".format(addr, value)
		mif.write(outstr)
		addr += 1
	
	addr_end = get_next_block(addr)	# round up to next block
	if addr_end-1 > addr:
		outstr = "\t[{:X}..{:X}] : {:08X};\n".format(addr, addr_end-1, 0)
		mif.write(outstr)
		
	print("bin2mif.. done")
	
	
	mif.write("END;\n")
	mif.close()
