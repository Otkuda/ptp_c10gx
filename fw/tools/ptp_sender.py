from scapy.all import *

IFACE = "Intel(R) Ethernet Connection (5) I219-LM"
SRC_MAC = "a4:4c:c8:59:7c:3c"


class IEEE1588(Packet):
    name = "IEEE1588"
    fields_desc = [
        BitField('transportSpecific', 0, 4),
        BitField('messageType', 0, 4),
        BitField('versionPTP', 2, 8),
        BitField('messageLength', 44, 16),
        BitField('subdomainNumber', 8, 0),
        BitField('dummy1', 8, 0),
        BitField('flags', 16, 0),
        BitField('correction', 64, 0),
        BitField('dummy2', 32, 0),
        BitField('ClockIdentity', 64, 0),
        BitField('SourcePortId', 16, 0),
        BitField('sequenceId', 16, 0),
        BitField('control', 8, 0),
        BitField('logMessagePeriod', 8, 0),
        BitField('TimestampSec', 48, 23),
        BitField('TimestampNanoSec', 32, 0)
    ]

bind_layers(Ether, IEEE1588, type=0x88f7)

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

    eth = Ether(dst="02:00:00:00:00:00", src=mac_addr)
    ptp = IEEE1588()
    pkt = eth / ptp

    sendp(pkt, iface=interface)
    

if __name__ == "__main__":
    main()