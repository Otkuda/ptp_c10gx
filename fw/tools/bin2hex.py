#!/usr/bin/python3
'''
converts riscv binary file to ihex format
3 Jun 2022 - initial file.  btko
'''
import sys
			
def twos_comp(val, bits):
	return((val ^ 2**bits-1) + 1)

	
def checksumit(bytecount, address, recordtype, data):
	sum = 0
	value = data
	value += recordtype << (4*8)
	value += address << (5*8)
	value += bytecount << (7*8)
	
	for i in range(8):
		sum += (0xff & (value >> (8*i)))
	sum = sum & 0xff
	return f":{value:0{16}X}{twos_comp(sum, 8):0{2}X}"
	

				
if __name__ == "__main__":
	bytecount = 4
	address = 0
	recordtype = 0
	if len(sys.argv) < 2:
		print('v'*50)
		print('__RiscV binary to Intel Hex converter__')
		print(f'usage:\n\t {sys.argv[0]} <infile.bin> <outfile.hex>')
		print('^'*50)
		sys.exit()
	infilename = sys.argv[1]
	outfilename = sys.argv[2]
	
	ihex = open(outfilename, 'w')
	
	with open(infilename, 'rb') as f:
		while True:
			chunk = f.read(bytecount)
			if chunk:
				data = int.from_bytes( chunk, 'little' )
				ihex.write(str(checksumit(bytecount, address, recordtype, data)) + '\n')
				address += 1
			else:
				break
		ihex.write(":00000001FF"+'\n')

	ihex.close()
	print("bin2hex.. done")
		
