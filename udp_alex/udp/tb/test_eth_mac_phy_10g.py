#!/usr/bin/env python
"""

Copyright (c) 2019 Alex Forencich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

"""

from myhdl import *
import os

import axis_ep
import eth_ep
import xgmii_ep
import baser_serdes_ep

module = 'eth_mac_phy_10g'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../rtl/axis_baser_tx_64.v")
srcs.append("../rtl/axis_baser_rx_64.v")
srcs.append("../rtl/eth_mac_phy_10g_rx.v")
srcs.append("../rtl/eth_mac_phy_10g_tx.v")
srcs.append("../rtl/eth_phy_10g_rx_if.v")
srcs.append("../rtl/eth_phy_10g_tx_if.v")
srcs.append("../rtl/eth_phy_10g_rx_ber_mon.v")
srcs.append("../rtl/eth_phy_10g_rx_frame_sync.v")
srcs.append("../rtl/lfsr.v")
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    DATA_WIDTH = 64
    KEEP_WIDTH = (DATA_WIDTH/8)
    HDR_WIDTH = (DATA_WIDTH/32)
    ENABLE_PADDING = 1
    ENABLE_DIC = 1
    MIN_FRAME_LENGTH = 64
    PTP_PERIOD_NS = 0x6
    PTP_PERIOD_FNS = 0x6666
    TX_PTP_TS_ENABLE = 0
    TX_PTP_TS_WIDTH = 96
    TX_PTP_TAG_ENABLE = TX_PTP_TS_ENABLE
    TX_PTP_TAG_WIDTH = 16
    RX_PTP_TS_ENABLE = 0
    RX_PTP_TS_WIDTH = 96
    TX_USER_WIDTH = (TX_PTP_TAG_WIDTH if TX_PTP_TAG_ENABLE else 0) + 1
    RX_USER_WIDTH = (RX_PTP_TS_WIDTH if RX_PTP_TS_ENABLE else 0) + 1
    BIT_REVERSE = 0
    SCRAMBLER_DISABLE = 0
    PRBS31_ENABLE = 1
    TX_SERDES_PIPELINE = 2
    RX_SERDES_PIPELINE = 2
    BITSLIP_HIGH_CYCLES = 1
    BITSLIP_LOW_CYCLES = 8
    COUNT_125US = 125000/6.4

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    rx_clk = Signal(bool(0))
    rx_rst = Signal(bool(0))
    tx_clk = Signal(bool(0))
    tx_rst = Signal(bool(0))
    tx_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    tx_axis_tkeep = Signal(intbv(0)[KEEP_WIDTH:])
    tx_axis_tvalid = Signal(bool(0))
    tx_axis_tlast = Signal(bool(0))
    tx_axis_tuser = Signal(intbv(0)[TX_USER_WIDTH:])
    serdes_rx_data = Signal(intbv(0)[DATA_WIDTH:])
    serdes_rx_hdr = Signal(intbv(1)[HDR_WIDTH:])
    tx_ptp_ts = Signal(intbv(0)[TX_PTP_TS_WIDTH:])
    rx_ptp_ts = Signal(intbv(0)[RX_PTP_TS_WIDTH:])
    ifg_delay = Signal(intbv(0)[8:])
    tx_prbs31_enable = Signal(bool(0))
    rx_prbs31_enable = Signal(bool(0))

    serdes_rx_data_int = Signal(intbv(0)[DATA_WIDTH:])
    serdes_rx_hdr_int = Signal(intbv(1)[HDR_WIDTH:])

    # Outputs
    tx_axis_tready = Signal(bool(0))
    rx_axis_tdata = Signal(intbv(0)[DATA_WIDTH:])
    rx_axis_tkeep = Signal(intbv(0)[KEEP_WIDTH:])
    rx_axis_tvalid = Signal(bool(0))
    rx_axis_tlast = Signal(bool(0))
    rx_axis_tuser = Signal(intbv(0)[RX_USER_WIDTH:])
    serdes_tx_data = Signal(intbv(0)[DATA_WIDTH:])
    serdes_tx_hdr = Signal(intbv(1)[HDR_WIDTH:])
    serdes_rx_bitslip = Signal(bool(0))
    tx_axis_ptp_ts = Signal(intbv(0)[TX_PTP_TS_WIDTH:])
    tx_axis_ptp_ts_tag = Signal(intbv(0)[TX_PTP_TAG_WIDTH:])
    tx_axis_ptp_ts_valid = Signal(bool(0))
    tx_start_packet = Signal(intbv(0)[2:])
    tx_error_underflow = Signal(bool(0))
    rx_start_packet = Signal(intbv(0)[2:])
    rx_error_count = Signal(intbv(0)[7:])
    rx_error_bad_frame = Signal(bool(0))
    rx_error_bad_fcs = Signal(bool(0))
    rx_bad_block = Signal(bool(0))
    rx_block_lock = Signal(bool(0))
    rx_high_ber = Signal(bool(0))

    # sources and sinks
    axis_source_pause = Signal(bool(0))

    serdes_source = baser_serdes_ep.BaseRSerdesSource()

    serdes_source_logic = serdes_source.create_logic(
        rx_clk,
        tx_data=serdes_rx_data_int,
        tx_header=serdes_rx_hdr_int,
        name='serdes_source'
    )

    serdes_sink = baser_serdes_ep.BaseRSerdesSink()

    serdes_sink_logic = serdes_sink.create_logic(
        tx_clk,
        rx_data=serdes_tx_data,
        rx_header=serdes_tx_hdr,
        name='serdes_sink'
    )

    axis_source = axis_ep.AXIStreamSource()

    axis_source_logic = axis_source.create_logic(
        tx_clk,
        tx_rst,
        tdata=tx_axis_tdata,
        tkeep=tx_axis_tkeep,
        tvalid=tx_axis_tvalid,
        tready=tx_axis_tready,
        tlast=tx_axis_tlast,
        tuser=tx_axis_tuser,
        pause=axis_source_pause,
        name='axis_source'
    )

    axis_sink = axis_ep.AXIStreamSink()

    axis_sink_logic = axis_sink.create_logic(
        rx_clk,
        rx_rst,
        tdata=rx_axis_tdata,
        tkeep=rx_axis_tkeep,
        tvalid=rx_axis_tvalid,
        tlast=rx_axis_tlast,
        tuser=rx_axis_tuser,
        name='axis_sink'
    )

    # DUT
    if os.system(build_cmd):
        raise Exception("Error running build command")

    dut = Cosimulation(
        "vvp -m ./myhdl.vpi %s.vvp -lxt2" % testbench,
        clk=clk,
        rst=rst,
        current_test=current_test,
        rx_clk=rx_clk,
        rx_rst=rx_rst,
        tx_clk=tx_clk,
        tx_rst=tx_rst,
        tx_axis_tdata=tx_axis_tdata,
        tx_axis_tkeep=tx_axis_tkeep,
        tx_axis_tvalid=tx_axis_tvalid,
        tx_axis_tready=tx_axis_tready,
        tx_axis_tlast=tx_axis_tlast,
        tx_axis_tuser=tx_axis_tuser,
        rx_axis_tdata=rx_axis_tdata,
        rx_axis_tkeep=rx_axis_tkeep,
        rx_axis_tvalid=rx_axis_tvalid,
        rx_axis_tlast=rx_axis_tlast,
        rx_axis_tuser=rx_axis_tuser,
        serdes_tx_data=serdes_tx_data,
        serdes_tx_hdr=serdes_tx_hdr,
        serdes_rx_data=serdes_rx_data,
        serdes_rx_hdr=serdes_rx_hdr,
        serdes_rx_bitslip=serdes_rx_bitslip,
        tx_ptp_ts=tx_ptp_ts,
        rx_ptp_ts=rx_ptp_ts,
        tx_axis_ptp_ts=tx_axis_ptp_ts,
        tx_axis_ptp_ts_tag=tx_axis_ptp_ts_tag,
        tx_axis_ptp_ts_valid=tx_axis_ptp_ts_valid,
        tx_start_packet=tx_start_packet,
        tx_error_underflow=tx_error_underflow,
        rx_start_packet=rx_start_packet,
        rx_error_count=rx_error_count,
        rx_error_bad_frame=rx_error_bad_frame,
        rx_error_bad_fcs=rx_error_bad_fcs,
        rx_bad_block=rx_bad_block,
        rx_block_lock=rx_block_lock,
        rx_high_ber=rx_high_ber,
        ifg_delay=ifg_delay,
        tx_prbs31_enable=tx_prbs31_enable,
        rx_prbs31_enable=rx_prbs31_enable
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk
        tx_clk.next = not tx_clk
        rx_clk.next = not rx_clk

    load_bit_offset = []

    @instance
    def shift_bits():
        bit_offset = 0
        last_data = 0

        while True:
            yield clk.posedge

            if load_bit_offset:
                bit_offset = load_bit_offset.pop(0)

            if serdes_rx_bitslip:
                bit_offset += 1

            bit_offset = bit_offset % 66

            data = int(serdes_rx_data_int) << 2 | int(serdes_rx_hdr_int)

            out_data = ((last_data | data << 66) >> 66-bit_offset) & 0x3ffffffffffffffff

            last_data = data

            serdes_rx_data.next = out_data >> 2
            serdes_rx_hdr.next = out_data & 3

    @instance
    def check():
        yield delay(100)
        yield clk.posedge
        rst.next = 1
        tx_rst.next = 1
        rx_rst.next = 1
        yield clk.posedge
        rst.next = 0
        tx_rst.next = 0
        rx_rst.next = 0
        yield clk.posedge
        yield delay(100)
        yield clk.posedge

        ifg_delay.next = 12

        # testbench stimulus

        # wait for block lock
        while not rx_block_lock:
            yield clk.posedge

        # dump garbage
        while not axis_sink.empty():
            axis_sink.recv()

        yield clk.posedge
        print("test 1: test rx packet")
        current_test.next = 1

        test_frame = eth_ep.EthFrame()
        test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame.eth_src_mac = 0x5A5152535455
        test_frame.eth_type = 0x8000
        test_frame.payload = bytearray(range(32))
        test_frame.update_fcs()

        axis_frame = test_frame.build_axis_fcs()

        serdes_source.send(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+bytearray(axis_frame))

        yield axis_sink.wait()
        rx_frame = axis_sink.recv()

        eth_frame = eth_ep.EthFrame()
        eth_frame.parse_axis(rx_frame)
        eth_frame.update_fcs()

        assert eth_frame == test_frame

        yield delay(100)

        yield clk.posedge
        print("test 2: test tx packet")
        current_test.next = 2

        test_frame = eth_ep.EthFrame()
        test_frame.eth_dest_mac = 0xDAD1D2D3D4D5
        test_frame.eth_src_mac = 0x5A5152535455
        test_frame.eth_type = 0x8000
        test_frame.payload = bytearray(range(32))
        test_frame.update_fcs()

        axis_frame = test_frame.build_axis()

        axis_source.send(axis_frame)

        yield serdes_sink.wait()
        rx_frame = serdes_sink.recv()

        assert rx_frame.data[0:8] == bytearray(b'\x55\x55\x55\x55\x55\x55\x55\xD5')

        eth_frame = eth_ep.EthFrame()
        eth_frame.parse_axis_fcs(rx_frame.data[8:])

        print(hex(eth_frame.eth_fcs))
        print(hex(eth_frame.calc_fcs()))

        assert len(eth_frame.payload.data) == 46
        assert eth_frame.eth_fcs == eth_frame.calc_fcs()
        assert eth_frame.eth_dest_mac == test_frame.eth_dest_mac
        assert eth_frame.eth_src_mac == test_frame.eth_src_mac
        assert eth_frame.eth_type == test_frame.eth_type
        assert eth_frame.payload.data.index(test_frame.payload.data) == 0

        yield delay(100)

        raise StopSimulation

    return instances()

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()
