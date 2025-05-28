from binascii import hexlify
from scapy.layers.l2 import Ether
from scapy.packet import Packet, bind_layers
from scapy.fields import *

# enable to debug dissectors
conf.debug_dissector = 1

class SixBytesField(Field):
    def __init__(self, name, default):
        Field.__init__(self, name, default, '!Q')

    def addfield(self, pkt, s, val):
        return s + struct.pack(self.fmt, self.i2m(pkt, val))[2:]

    def getfield(self, pkt, s):
        return s[6:], self.m2i(pkt, struct.unpack(self.fmt, b'\x00\x00' + s[:6])[0])

class TimestampField(Field):
    def __init__(self, name, default):
        Field.__init__(self, name, default, '!QL')

    def addfield(self, pkt, s, val):
        mval = self.i2m(pkt, val)
        intpart, decpart = int(mval), mval - int(mval)
        return s + struct.pack(self.fmt, intpart, int(decpart * 10**9))[2:]

    def getfield(self, pkt, s):
        (intpart, decpart) = struct.unpack(self.fmt, b'\x00\x00' + s[:10])
        mval = intpart + decpart * 10**-9
        return s[10:], self.m2i(pkt, mval)

    def i2repr(self, pkt, x):
        """Convert internal value to a nice representation"""
        return repr(self.i2h(pkt, x)) + ' secs'

class ScaledNsField(Field):
    def __init__(self, name, default):
        Field.__init__(self, name, default, '!LQ')

    def addfield(self, pkt, s, val):
        mval = self.i2m(pkt, val)
        return s + struct.pack(self.fmt, (mval >> 64) & 0xFFFFFFFF, mval & 0xFFFFFFFFFFFFFFFF)

    def getfield(self, pkt, s):
        (u, l) = struct.unpack(self.fmt, s[:12])
        mval = (u << 64) + l
        bits = 96
        if (mval & (1 << (bits - 1))) != 0:
            mval = mval - (1 << bits)        # compute negative value
        return s[12:], self.m2i(pkt, mval)

    def h2i(self, pkt, x):
        """Convert human value to internal value"""
        return int(x * 2**16)

    def i2h(self, pkt, x):
        """Convert internal value to human value"""
        return x * 2**-16

    def i2repr(self, pkt, x):
        """Convert internal value to a nice representation"""
        return repr(self.i2h(pkt, x)) + ' ns'

class _PTPPacketBase(Packet):
    """ base class to be used among all PTP Packet definitions."""
    # use this dictionary to set default values for desired fields (mostly on subclasses
    # where not all fields are defined locally)
    # - key : field_name, value : desired value
    # - it will be used from 'init_fields' function, upon packet initialization
    #
    # example : _defaults = {'field_1_name':field_1_value,'field_2_name':field_2_value}
    _defaults = {}

    def _set_defaults(self):
        """ goes through '_defaults' dict setting field default values (for those that have been defined)."""
        for key in self._defaults.keys():
            try:
                self.get_field(key)
            except KeyError:
                pass
            else:
                self.setfieldval(key, self._defaults[key])

    def init_fields(self):
        """ perform initialization of packet fields with desired values.
            NOTE : this funtion will only be called *once* upon class (or subclass) construction
        """
        Packet.init_fields(self)
        self._set_defaults()

class PortIdentity(_PTPPacketBase):
    fields_desc = [
        XLongField('clockIdentity', 0), # TODO: enhance to support EUI-64 input format
        XShortField('portNumber', 0),
    ]

    def extract_padding(self, p):
        return '', p

class ieee1588(_PTPPacketBase):
    MSG_TYPE_SYNC = 0
    MSG_TYPE_DELAY_REQ = 1
    MSG_TYPE_PDELAY_REQ = 2
    MSG_TYPE_PDELAY_RESP = 3
    MSG_TYPE_FOUR = 4
    MSG_TYPE_FIVE = 5
    MSG_TYPE_SIX = 6
    MSG_TYPE_SEVEN = 7
    MSG_TYPE_FOLLOW_UP = 8
    MSG_TYPE_DELAY_RESP = 9
    MSG_TYPE_PDELAY_RESP_FOLLOW_UP = 0xA
    MSG_TYPE_ANNOUNCE = 0xB
    MSG_TYPE_SIGNALING = 0xC
    MSG_TYPE_MANAGEMENT = 0xD
    MSG_TYPE_FOURTEEN = 0xE
    MSG_TYPE_FIFTEEN = 0xF

    def guess_payload_class(self, payload):
        """ decode ieee1588 frame depending on its type."""

        # if the payload is not long enough
        if len(payload) <= 4:
            return None

        (byte0, byte1) = struct.unpack('!BB', payload[0:2])
        transportSpecific = byte0 >> 4
        messageType = byte0 & 0xF
        version = byte1 & 0xF

        if version == 2:
            if messageType == self.MSG_TYPE_SYNC:
                return ieee1588v2_Sync
            elif messageType == self.MSG_TYPE_DELAY_REQ:
                return ieee1588v2_Delay_Req
            elif messageType == self.MSG_TYPE_PDELAY_REQ:
                return ieee1588v2_PDelay_Req
            elif messageType == self.MSG_TYPE_PDELAY_RESP:
                return ieee1588v2_PDelay_Resp
            elif messageType == self.MSG_TYPE_FOLLOW_UP:
                return ieee1588v2_Follow_Up
            elif messageType == self.MSG_TYPE_DELAY_RESP:
                return ieee1588v2_Delay_Resp
            elif messageType == self.MSG_TYPE_PDELAY_RESP_FOLLOW_UP:
                return ieee1588v2_PDelay_Resp_Follow_Up
            elif messageType == self.MSG_TYPE_SIGNALING:
                return ieee1588v2_Signaling
            elif messageType == self.MSG_TYPE_MANAGEMENT:
                return ieee1588v2_Management

        return ieee1588v2_Header


class ieee1588v2_Header(ieee1588):
    fields_desc = [
        BitEnumField('transportSpecific', 1, 4, {0: 'Default', 1: '802.1as'}),
        BitEnumField('messageType', 0, 4, {ieee1588.MSG_TYPE_SYNC: 'Sync', ieee1588.MSG_TYPE_PDELAY_REQ: 'PDelay_Req',
            ieee1588.MSG_TYPE_PDELAY_RESP: 'PDelay_Resp', ieee1588.MSG_TYPE_FOLLOW_UP: 'Follow_Up',
            ieee1588.MSG_TYPE_PDELAY_RESP_FOLLOW_UP: 'PDelay_Resp_Follow_Up', ieee1588.MSG_TYPE_ANNOUNCE: 'Announce',
            ieee1588.MSG_TYPE_SIGNALING: 'Signaling'}),
        BitField('reserved0', 0, 4),
        BitField('versionPTP', 2, 4),
        ShortField('messageLength', None),
        ByteField('domainNumber', 0),
        ByteField('reserved1', 0),
        FlagsField('flagField', 0, 16, ['PTP_LI_61', 'PTP_LI_59', 'PTP_UTC_REASONABLE', 'PTP_TIMESCALE', 'TIME_TRACEABLE',
            'FREQUENCY_TRACEABLE', 'UNDEF', 'UNDEF', 'PTP_ALTERNATE_MASTER', 'PTP_TWO_STEPS', 'PTP_UNICAST', 'UNDEF',
            'UNDEF', 'PTP_PROFILE_V1', 'PTP_PROFILE_V2', 'PTP_SECURITY']),
        LongField('correctionField', 0),
        IntField('reserved2', 0),
        PacketField('sourcePortIdentity', PortIdentity(), PortIdentity),
        XShortField('sequenceId', 0),
        ByteField('controlField', 0),
        SignedByteField('logMessageInterval', 0)
    ]

    def post_build(self, p, pay):
        ml = self.messageLength
        if ml is None:
            ml = len(p)
            p = p[:2] + struct.pack("!H", ml) + p[4:]
        return p + pay


class ieee1588v2_TLV_Header(ieee1588):
    fields_desc = [
        ShortEnumField('tlvType', 0, {3: 'Organisation extension', 8: 'Path trace'}),
        ShortField('lengthField', None),
    ]

    def post_build(self, p, pay):
        lf = self.lengthField
        if lf is None:
            lf = len(p) - 4
            p = p[:2] + struct.pack("!H", lf) + p[4:]
        return p + pay


class ieee1588v2_TLV_Follow_Up(ieee1588v2_TLV_Header):
    _defaults = {'tlvType': 3}
    fields_desc = [
        ieee1588v2_TLV_Header,
        X3BytesField('organizationId', 0x0080C2),
        X3BytesField('organizationSubType', 1),
        SignedIntField('cumulativeScaledRateOffset', 0),
        ShortField('gmTimeBaseIndicator', 0),
        ScaledNsField('lastGmPhaseChange', 0),
        SignedIntField('scaledLastGmFreqChange', 0),
    ]

class ieee1588v2_Sync(ieee1588v2_Header):
    name = 'Precision Time Protocol Sync'

    # default values specification
    _defaults = {'messageType': ieee1588.MSG_TYPE_SYNC,
                 'controlField': 0}

    fields_desc = [
        ieee1588v2_Header,
        TimestampField('originTimestamp', 0),
    ]

class ieee1588v2_Delay_Req(ieee1588v2_Header):
    name = 'Precision Time Protocol Sync'

    # default values specification
    _defaults = {'messageType': ieee1588.MSG_TYPE_DELAY_REQ,
                 'controlField': 1}

    fields_desc = [
        ieee1588v2_Header,
        TimestampField('originTimestamp', 0),
    ]

class ieee1588v2_PDelay_Req(ieee1588v2_Header):
    name = 'Precision Time Protocol Peer Delay Request'

    # default values specification
    _defaults = {'messageType': ieee1588.MSG_TYPE_PDELAY_REQ,
                 'controlField': 5}

    fields_desc = [
        ieee1588v2_Header,
        TimestampField('originTimestamp', 0),
        TimestampField('reserved ', 0),
    ]

class ieee1588v2_PDelay_Resp(ieee1588v2_Header):
    name = 'Precision Time Protocol Peer Delay Response'

    # default values specification
    _defaults = {'messageType': ieee1588.MSG_TYPE_PDELAY_RESP,
                 'controlField': 5}

    fields_desc = [
        ieee1588v2_Header,
        TimestampField('requestReceiptTimestamp', 0),
        PacketField('requestingPortIdentity', PortIdentity(), PortIdentity),
    ]

class ieee1588v2_Follow_Up(ieee1588v2_Header):
    name = 'Precision Time Protocol Follow Up'

    # default values specification
    _defaults = {'messageType': ieee1588.MSG_TYPE_FOLLOW_UP,
                 'controlField': 2}

    fields_desc = [
        ieee1588v2_Header,
        TimestampField('preciseOriginTimestamp', 0),
        PacketLenField("TLV", None, ieee1588v2_TLV_Follow_Up, length_from = lambda pkt:pkt.messageLength - 44),
    ]

class ieee1588v2_Delay_Resp(ieee1588v2_Header):
    name = 'Precision Time Protocol Delay Response'

    # default values specification
    _defaults = {'messageType': ieee1588.MSG_TYPE_DELAY_RESP,
                 'controlField': 3}

    fields_desc = [
        ieee1588v2_Header,
        TimestampField('receiveTimestamp', 0),
        PacketField('requestingPortIdentity', PortIdentity(), PortIdentity),
    ]

class ieee1588v2_PDelay_Resp_Follow_Up(ieee1588v2_Header):
    name = 'Precision Time Protocol Peer Delay Response Follow Up'

    # default values specification
    _defaults = {'messageType': ieee1588.MSG_TYPE_PDELAY_RESP_FOLLOW_UP,
                 'controlField': 5}

    fields_desc = [
        ieee1588v2_Header,
        TimestampField('responseOriginTimestamp', 0),
        PacketField('requestingPortIdentity', PortIdentity(), PortIdentity),
    ]

class ieee1588v2_Signaling(ieee1588v2_Header):
    name = 'Precision Time Protocol Signaling'

    # default values specification
    _defaults = {'messageType': ieee1588.MSG_TYPE_SIGNALING,
                 'controlField': 5}

    fields_desc = [
        ieee1588v2_Header,
        PacketField('targetPortIdentity', PortIdentity(), PortIdentity),
        PacketListField("TLV", None, ieee1588v2_TLV_Follow_Up, length_from = lambda pkt:pkt.messageLength - 44),
    ]

class ieee1588v2_Management(ieee1588v2_Header):
    name = 'Precision Time Protocol Management'

    # default values specification
    _defaults = {'messageType': ieee1588.MSG_TYPE_MANAGEMENT,
                 'controlField': 4,
                 }

    fields_desc = [
        ieee1588v2_Header,
        PacketField('targetPortIdentity', PortIdentity(), PortIdentity),
        ByteField('startingBoundaryHops', 0),
        ByteField('boundaryHops', 0),
        BitField('reserved0', None, 4),
        BitField('actionField', 0, 4),
        ByteField('reserved1', None),
        PacketListField("TLV", None, ieee1588v2_TLV_Follow_Up, length_from = lambda pkt:pkt.messageLength - 48),
    ]


bind_layers(Ether, ieee1588, dst='01:80:c2:00:00:0e', type=0x88F7)