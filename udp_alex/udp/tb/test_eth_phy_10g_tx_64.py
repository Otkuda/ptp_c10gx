#!/usr/bin/env python
"""

Copyright (c) 2018 Alex Forencich

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

module = 'eth_phy_10g_tx'
testbench = 'test_%s_64' % module

srcs = []

srcs.append("../rtl/%s.v" % module)
srcs.append("../rtl/eth_phy_10g_tx_if.v")
srcs.append("../rtl/xgmii_baser_enc_64.v")
srcs.append("../rtl/lfsr.v")
srcs.append("%s.v" % testbench)

src = ' '.join(srcs)

build_cmd = "iverilog -o %s.vvp %s" % (testbench, src)

def prbs31(width=8, state=0x7fffffff):
    while True:
        out = 0
        for i in range(width):
            if bool(state & 0x08000000) ^ bool(state & 0x40000000):
                state = ((state & 0x3fffffff) << 1) | 1
                out = out | 2**i
            else:
                state = (state & 0x3fffffff) << 1
        yield ~out & (2**width-1)

def bench():

    # Parameters
    DATA_WIDTH = 64
    CTRL_WIDTH = (DATA_WIDTH/8)
    HDR_WIDTH = 2
    BIT_REVERSE = 0
    SCRAMBLER_DISABLE = 0
    PRBS31_ENABLE = 1
    SERDES_PIPELINE = 2

    # Inputs
    clk = Signal(bool(0))
    rst = Signal(bool(0))
    current_test = Signal(intbv(0)[8:])

    xgmii_txd = Signal(intbv(0)[DATA_WIDTH:])
    xgmii_txc = Signal(intbv(0)[CTRL_WIDTH:])
    tx_prbs31_enable = Signal(bool(0))

    # Outputs
    serdes_tx_data = Signal(intbv(0)[DATA_WIDTH:])
    serdes_tx_hdr = Signal(intbv(0)[HDR_WIDTH:])

    # sources and sinks
    source = xgmii_ep.XGMIISource()

    source_logic = source.create_logic(
        clk,
        rst,
        txd=xgmii_txd,
        txc=xgmii_txc,
        name='source'
    )

    sink = baser_serdes_ep.BaseRSerdesSink()

    sink_logic = sink.create_logic(
        clk,
        rx_data=serdes_tx_data,
        rx_header=serdes_tx_hdr,
        name='sink'
    )

    # DUT
    if os.system(build_cmd):
        raise Exception("Error running build command")

    dut = Cosimulation(
        "vvp -m ./myhdl.vpi %s.vvp -lxt2" % testbench,
        clk=clk,
        rst=rst,
        current_test=current_test,
        xgmii_txd=xgmii_txd,
        xgmii_txc=xgmii_txc,
        serdes_tx_data=serdes_tx_data,
        serdes_tx_hdr=serdes_tx_hdr,
        tx_prbs31_enable=tx_prbs31_enable
    )

    @always(delay(4))
    def clkgen():
        clk.next = not clk

    @instance
    def check():
        yield delay(100)
        yield clk.posedge
        rst.next = 1
        yield clk.posedge
        rst.next = 0
        yield clk.posedge
        yield delay(100)
        yield clk.posedge

        # testbench stimulus

        for payload_len in list(range(16,34)):
            yield clk.posedge
            print("test 1: test packet, length %d" % payload_len)
            current_test.next = 1

            test_frame = bytearray(range(payload_len))

            xgmii_frame = xgmii_ep.XGMIIFrame(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+test_frame)

            source.send(xgmii_frame)

            yield sink.wait()
            rx_frame = sink.recv()

            assert rx_frame.data == xgmii_frame.data

            assert sink.empty()

            yield delay(100)

            yield clk.posedge
            print("test 2: back-to-back packets, length %d" % payload_len)
            current_test.next = 2

            test_frame1 = bytearray(range(payload_len))
            test_frame2 = bytearray(range(payload_len))

            xgmii_frame1 = xgmii_ep.XGMIIFrame(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+test_frame1)
            xgmii_frame2 = xgmii_ep.XGMIIFrame(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+test_frame2)

            source.send(xgmii_frame1)
            source.send(xgmii_frame2)

            yield sink.wait()
            rx_frame = sink.recv()

            assert rx_frame.data == xgmii_frame1.data

            yield sink.wait()
            rx_frame = sink.recv()

            assert rx_frame.data == xgmii_frame2.data

            assert sink.empty()

            yield delay(100)

            yield clk.posedge
            print("test 3: errored frame, length %d" % payload_len)
            current_test.next = 3

            test_frame1 = bytearray(range(payload_len))
            test_frame2 = bytearray(range(payload_len))

            xgmii_frame1 = xgmii_ep.XGMIIFrame(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+test_frame1)
            xgmii_frame2 = xgmii_ep.XGMIIFrame(b'\x55\x55\x55\x55\x55\x55\x55\xD5'+test_frame2)

            xgmii_frame1.error = 1

            source.send(xgmii_frame1)
            source.send(xgmii_frame2)

            yield sink.wait()
            rx_frame = sink.recv()

            #assert rx_frame.data == xgmii_frame1.data

            yield sink.wait()
            rx_frame = sink.recv()

            assert rx_frame.data == xgmii_frame2.data

            assert sink.empty()

            yield delay(100)

        yield clk.posedge
        print("test 4: PRBS31 generation")
        current_test.next = 4

        tx_prbs31_enable.next = True

        yield delay(100)

        prbs_gen = prbs31(66)
        prbs_data = [next(prbs_gen) for x in range(100)]

        for k in range(20):
            yield clk.posedge
            data = int(serdes_tx_data) << 2 | int(serdes_tx_hdr)
            assert data in prbs_data

        tx_prbs31_enable.next = False

        yield delay(100)

        raise StopSimulation

    return instances()

def test_bench():
    sim = Simulation(bench())
    sim.run()

if __name__ == '__main__':
    print("Running test...")
    test_bench()
