#!/usr/bin/env python
"""

Copyright (c) 2015-2018 Alex Forencich

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
import gmii_ep

module = 'eth_mac_1g_fifo'
testbench = 'test_%s' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../rtl/lfsr.v")
srcs.append("../rtl/axis_gmii_rx.v")
srcs.append("../rtl/axis_gmii_tx.v")
srcs.append("../rtl/eth_mac_1g.v")
srcs.append("../../axis/rtl/axis_async_fifo.v")
srcs.append("../../axis/rtl/axis_async_fifo_adapter.v")
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def bench():

    # Parameters
    AXIS_DATA_WIDTH = 8
    AXIS_KEEP_ENABLE = (AXIS_DATA_WIDTH>8)
    AXIS_KEEP_WIDTH = (AXIS_DATA_WIDTH/8)
    ENABLE_PADDING = 1
    MIN_FRAME_LENGTH = 64
    TX_FIFO_DEPTH = 4096
    TX_FIFO_PIPELINE_OUTPUT = 2
    TX_FRAME_FIFO = 1
    TX_DROP_BAD_FRAME = TX_FRAME_FIFO
    TX_DROP_WHEN_FULL = 0
    RX_FIFO_DEPTH = 4096
    RX_FIFO_PIPELINE_OUTPUT = 2
    RX_FRAME_FIFO = 1
    RX_DROP_BAD_FRAME = RX_FRAME_FIFO
    RX_DROP_WHEN_FULL = RX_FRAME_FIFO

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    rx_clk = Signal(bool(0))
    rx_rst = Signal(bool(0))
    tx_clk = Signal(bool(0))
    tx_rst = Signal(bool(0))
    logic_clk = Signal(bool(0))
    logic_rst = Signal(bool(0))
    tx_axis_tdata = Signal(intbv(0)[AXIS_DATA_WIDTH:])
    tx_axis_tkeep = Signal(intbv(1)[AXIS_KEEP_WIDTH:])
    tx_axis_tvalid = Signal(bool(0))
    tx_axis_tlast = Signal(bool(0))
    tx_axis_tuser = Signal(bool(0))
    rx_axis_tready = Signal(bool(0))
    gmii_rxd = Signal(intbv(0)[8:])
    gmii_rx_dv = Signal(bool(0))
    gmii_rx_er = Signal(bool(0))
    rx_clk_enable = Signal(bool(1))
    tx_clk_enable = Signal(bool(1))
    rx_mii_select = Signal(bool(0))
    tx_mii_select = Signal(bool(0))
    ifg_delay = Signal(intbv(0)[8:])

    # Outputs
    tx_axis_tready = Signal(bool(0))
    rx_axis_tdata = Signal(intbv(0)[AXIS_DATA_WIDTH:])
    rx_axis_tkeep = Signal(intbv(1)[AXIS_KEEP_WIDTH:])
    rx_axis_tvalid = Signal(bool(0))
    rx_axis_tlast = Signal(bool(0))
    rx_axis_tuser = Signal(bool(0))
    gmii_txd = Signal(intbv(0)[8:])
    gmii_tx_en = Signal(bool(0))
    gmii_tx_er = Signal(bool(0))
    tx_error_underflow = Signal(bool(0))
    tx_fifo_overflow = Signal(bool(0))
    tx_fifo_bad_frame = Signal(bool(0))
    tx_fifo_good_frame = Signal(bool(0))
    rx_error_bad_frame = Signal(bool(0))
    rx_error_bad_fcs = Signal(bool(0))
    rx_fifo_overflow = Signal(bool(0))
    rx_fifo_bad_frame = Signal(bool(0))
    rx_fifo_good_frame = Signal(bool(0))

    # sources and sinks
    axis_source_pause = Signal(bool(0))
    axis_sink_pause = Signal(bool(0))

    gmii_source = gmii_ep.GMIISource()

    gmii_source_logic = gmii_source.create_logic(
        rx_clk,
        rx_rst,
        txd=gmii_rxd,
        tx_en=gmii_rx_dv,
        tx_er=gmii_rx_er,
        clk_enable=rx_clk_enable,
        mii_select=rx_mii_select,
        name='gmii_source'
    )

    gmii_sink = gmii_ep.GMIISink()

    gmii_sink_logic = gmii_sink.create_logic(
        tx_clk,
        tx_rst,
        rxd=gmii_txd,
        rx_dv=gmii_tx_en,
        rx_er=gmii_tx_er,
        clk_enable=tx_clk_enable,
        mii_select=tx_mii_select,
        name='gmii_sink'
    )

    axis_source = axis_ep.AXIStreamSource()

    axis_source_logic = axis_source.create_logic(
        logic_clk,
        logic_rst,
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
        logic_clk,
        logic_rst,
        tdata=rx_axis_tdata,
        tkeep=rx_axis_tkeep,
        tvalid=rx_axis_tvalid,
        tready=rx_axis_tready,
        tlast=rx_axis_tlast,
        tuser=rx_axis_tuser,
        pause=axis_sink_pause,
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
        logic_clk=logic_clk,
        logic_rst=logic_rst,

        tx_axis_tdata=tx_axis_tdata,
        tx_axis_tkeep=tx_axis_tkeep,
        tx_axis_tvalid=tx_axis_tvalid,
        tx_axis_tready=tx_axis_tready,
        tx_axis_tlast=tx_axis_tlast,
        tx_axis_tuser=tx_axis_tuser,

        rx_axis_tdata=rx_axis_tdata,
        rx_axis_tkeep=rx_axis_tkeep,
        rx_axis_tvalid=rx_axis_tvalid,
        rx_axis_tready=rx_axis_tready,
        rx_axis_tlast=rx_axis_tlast,
        rx_axis_tuser=rx_axis_tuser,

        gmii_rxd=gmii_rxd,
        gmii_rx_dv=gmii_rx_dv,
        gmii_rx_er=gmii_rx_er,

        gmii_txd=gmii_txd,
        gmii_tx_en=gmii_tx_en,
        gmii_tx_er=gmii_tx_er,

        rx_clk_enable=rx_clk_enable,
        tx_clk_enable=tx_clk_enable,

        rx_mii_select=rx_mii_select,
        tx_mii_select=tx_mii_select,

        tx_error_underflow=tx_error_underflow,
        tx_fifo_overflow=tx_fifo_overflow,
        tx_fifo_bad_frame=tx_fifo_bad_frame,
        tx_fifo_good_frame=tx_fifo_good_frame,
        rx_error_bad_frame=rx_error_bad_frame,
        rx_error_bad_fcs=rx_error_bad_fcs,
        rx_fifo_overflow=rx_fifo_overflow,
        rx_fifo_bad_frame=rx_fifo_bad_frame,
        rx_fifo_good_frame=rx_fifo_good_frame,

        ifg_delay=ifg_delay
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk
        tx_clk.next = not tx_clk
        rx_clk.next = not rx_clk
        logic_clk.next = not logic_clk

    rx_error_bad_frame_asserted = Signal(bool(0))
    rx_error_bad_fcs_asserted = Signal(bool(0))

    @always(clk.posedge)
    def monitor():
        if (rx_error_bad_frame):
            rx_error_bad_frame_asserted.next = 1
        if (rx_error_bad_fcs):
            rx_error_bad_fcs_asserted.next = 1

    clk_enable_rate = Signal(int(0))
    clk_enable_div = Signal(int(0))

    @always(clk.posedge)
    def clk_enable_gen():
        if clk_enable_div.next > 0:
            rx_clk_enable.next = 0
            tx_clk_enable.next = 0
            clk_enable_div.next = clk_enable_div - 1
        else:
            rx_clk_enable.next = 1
            tx_clk_enable.next = 1
            clk_enable_div.next = clk_enable_rate - 1

    @instance
    def check():
        yield delay(100)
        yield clk.posedge
        rst.next = 1
        tx_rst.next = 1
        rx_rst.next = 1
        logic_rst.next = 1
        yield clk.posedge
        rst.next = 0
        tx_rst.next = 0
        rx_rst.next = 0
        logic_rst.next = 0
        yield clk.posedge
        yield delay(100)
        yield clk.posedge

        ifg_delay.next = 12

        # testbench stimulus

        for rate, mii in [(1, 0), (10, 0), (5, 1)]:
            clk_enable_rate.next = rate
            rx_mii_select.next = mii
            tx_mii_select.next = mii

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

            gmii_source.send(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+bytearray(axis_frame))

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

            yield gmii_sink.wait()
            rx_frame = gmii_sink.recv()

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
