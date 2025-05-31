from scapy.all import *
#from eth_scapy_ieee1588 import *


IFACE = "Intel(R) Ethernet Connection (5) I219-LM"
SRC_MAC = "a4:4c:c8:59:7c:3c"

class myieee1588(Packet):
    name = "Precision Time Protocol"
    fields_desc = [
        XBitField('transportSpecific', 0x0, 4),
        XBitField('messageType', 0x0, 4),
        XByteField('versionPTP', 0x02),
        XShortField('messageLength', 0x002c),
        XByteField('subdomainNumber', 0x00),
        XByteField('none1', 0x00),
        XShortField('flags', 0x0200),
        XBitField('correction', 0x0, 64),
        XBitField('none2', 0x0, 32),
        XBitField('clockIdentity', 0x08028efffe9b97a5, 64),
        XShortField('sourcePortID', 0x01),
        XShortField('sequenceID', 0x01),
        XByteField('control', 0x00),
        XByteField('logMessagePeriod', 0x0),
        XBitField('timestampSec', 0x000000000030, 48),
        XBitField('timestampNSec', 0x0af320c0, 32)
    ]

bind_layers(Ether, myieee1588, type=0x88f7)

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

    mac_addr = "a4:4c:c8:59:7c:3c"
    interface = ifaces[interface_index]

    eth = Ether(src=mac_addr)
    ptp_sync = myieee1588(messageType=0, control=0)
    ptp_fu = myieee1588(messageType=8, control=8, timestampNSec=0xb165c48)
    sync_pkt = eth / ptp_sync
    fu_pkt = eth / ptp_fu
    resp = eth / myieee1588(messageType=9, control=9, timestampNSec=0xb615f68)

    sendp(sync_pkt, iface=interface)
    sendp(fu_pkt, iface=interface)
    sniff(1, prn=lambda x: print(x), iface=interface)
    sendp(resp, iface=interface)

def find_fu(x):
    resp = Ether(src="a4:4c:c8:59:7c:3c") / myieee1588(messageType=1, control=1)

if __name__ == "__main__":
    main()