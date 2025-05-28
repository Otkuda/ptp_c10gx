from scapy.all import *
from eth_scapy_ieee1588 import *


IFACE = "Intel(R) Ethernet Connection (5) I219-LM"
SRC_MAC = "a4:4c:c8:59:7c:3c"



def main():
    ifaces = get_if_list()
    my_macs = [get_if_hwaddr(i) for i in get_if_list()]
    
    print(f"#\tMAC\t\t\tInterface")
    for i, iface in enumerate(ifaces):
        print(f"{i}\t{my_macs[i]}\t{resolve_iface(iface).name}")
    
    print()
    try:
        interface_index = int(input("Choose interface number: "))
        if not (-1 < interface_index < len(ifaces)):
            raise Exception("Number must be in bounds")
    except:
        print("Invalid input")
        return

    mac_addr = my_macs[interface_index]
    interface = ifaces[interface_index]

    eth = Ether(src=mac_addr)
    ptp = ieee1588()
    pkt = eth / ptp

    sendp(pkt, iface=interface)
    

if __name__ == "__main__":
    main()