#!/usr/bin/env python
"""

Copyright (c) 2020 Alex Forencich

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

import itertools
import logging
import os

import cocotb_test.simulator

import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.regression import TestFactory

from cocotbext.eth import GmiiFrame, RgmiiPhy
from cocotbext.axi import AxiStreamBus, AxiStreamSource, AxiStreamSink, AxiStreamFrame


class TB:
    def __init__(self, dut, speed=1000e6):
        self.dut = dut

        self.log = logging.getLogger("cocotb.tb")
        self.log.setLevel(logging.DEBUG)

        self.rgmii_phy = RgmiiPhy(dut.rgmii_txd, dut.rgmii_tx_ctl, dut.rgmii_tx_clk,
            dut.rgmii_rxd, dut.rgmii_rx_ctl, dut.rgmii_rx_clk, speed=speed)

        self.axis_source = AxiStreamSource(AxiStreamBus.from_prefix(dut, "tx_axis"), dut.tx_clk, dut.tx_rst)
        self.axis_sink = AxiStreamSink(AxiStreamBus.from_prefix(dut, "rx_axis"), dut.rx_clk, dut.rx_rst)

        dut.cfg_ifg.setimmediatevalue(0)
        dut.cfg_tx_enable.setimmediatevalue(0)
        dut.cfg_rx_enable.setimmediatevalue(0)

        dut.gtx_clk.setimmediatevalue(0)
        dut.gtx_clk90.setimmediatevalue(0)

        cocotb.start_soon(self._run_gtx_clk())

    async def reset(self):
        self.dut.gtx_rst.setimmediatevalue(0)
        await RisingEdge(self.dut.gtx_clk)
        await RisingEdge(self.dut.gtx_clk)
        self.dut.gtx_rst.value = 1
        await RisingEdge(self.dut.gtx_clk)
        await RisingEdge(self.dut.gtx_clk)
        self.dut.gtx_rst.value = 0
        await RisingEdge(self.dut.gtx_clk)
        await RisingEdge(self.dut.gtx_clk)

    async def _run_gtx_clk(self):
        t = Timer(2, 'ns')
        while True:
            self.dut.gtx_clk.value = 1
            await t
            self.dut.gtx_clk90.value = 1
            await t
            self.dut.gtx_clk.value = 0
            await t
            self.dut.gtx_clk90.value = 0
            await t


async def run_test_rx(dut, payload_lengths=None, payload_data=None, ifg=12, speed=1000e6):

    tb = TB(dut, speed)

    tb.rgmii_phy.rx.ifg = ifg
    tb.dut.cfg_ifg.value = ifg
    tb.dut.cfg_rx_enable.value = 1

    await tb.reset()

    for k in range(100):
        await RisingEdge(dut.rx_clk)

    if speed == 10e6:
        assert dut.speed == 0
    elif speed == 100e6:
        assert dut.speed == 1
    else:
        assert dut.speed == 2

    test_frames = [payload_data(x) for x in payload_lengths()]

    for test_data in test_frames:
        test_frame = GmiiFrame.from_payload(test_data)
        await tb.rgmii_phy.rx.send(test_frame)

    for test_data in test_frames:
        rx_frame = await tb.axis_sink.recv()

        assert rx_frame.tdata == test_data
        assert rx_frame.tuser == 0

    assert tb.axis_sink.empty()

    await RisingEdge(dut.rx_clk)
    await RisingEdge(dut.rx_clk)


async def run_test_tx(dut, payload_lengths=None, payload_data=None, ifg=12, speed=1000e6):

    tb = TB(dut, speed)

    tb.rgmii_phy.rx.ifg = ifg
    tb.dut.cfg_ifg.value = ifg
    tb.dut.cfg_tx_enable.value = 1

    await tb.reset()

    for k in range(100):
        await RisingEdge(dut.rx_clk)

    if speed == 10e6:
        assert dut.speed == 0
    elif speed == 100e6:
        assert dut.speed == 1
    else:
        assert dut.speed == 2

    test_frames = [payload_data(x) for x in payload_lengths()]

    for test_data in test_frames:
        await tb.axis_source.send(test_data)

    for test_data in test_frames:
        rx_frame = await tb.rgmii_phy.tx.recv()

        assert rx_frame.get_payload() == test_data
        assert rx_frame.check_fcs()
        assert rx_frame.error is None

    assert tb.rgmii_phy.tx.empty()

    await RisingEdge(dut.tx_clk)
    await RisingEdge(dut.tx_clk)


async def run_test_tx_underrun(dut, ifg=12, speed=1000e6):

    tb = TB(dut, speed)

    tb.rgmii_phy.rx.ifg = ifg
    tb.dut.cfg_ifg.value = ifg
    tb.dut.cfg_tx_enable.value = 1

    await tb.reset()

    for k in range(100):
        await RisingEdge(dut.rx_clk)

    test_data = bytes(x for x in range(60))

    for k in range(3):
        test_frame = AxiStreamFrame(test_data)
        await tb.axis_source.send(test_frame)

    for k in range(200 if speed != 1000e6 else 100):
        while True:
            await RisingEdge(dut.tx_clk)
            if dut.mac_gmii_tx_clk_en.value.integer:
                break

    tb.axis_source.pause = True

    for k in range(10):
        while True:
            await RisingEdge(dut.tx_clk)
            if dut.mac_gmii_tx_clk_en.value.integer:
                break

    tb.axis_source.pause = False

    for k in range(3):
        rx_frame = await tb.rgmii_phy.tx.recv()

        if k == 1:
            assert rx_frame.error[-1] == 1
        else:
            assert rx_frame.get_payload() == test_data
            assert rx_frame.check_fcs()
            assert rx_frame.error is None

    assert tb.rgmii_phy.tx.empty()

    await RisingEdge(dut.tx_clk)
    await RisingEdge(dut.tx_clk)


async def run_test_tx_error(dut, ifg=12, speed=1000e6):

    tb = TB(dut, speed)

    tb.rgmii_phy.rx.ifg = ifg
    tb.dut.cfg_ifg.value = ifg
    tb.dut.cfg_tx_enable.value = 1

    await tb.reset()

    for k in range(100):
        await RisingEdge(dut.rx_clk)

    test_data = bytes(x for x in range(60))

    for k in range(3):
        test_frame = AxiStreamFrame(test_data)
        if k == 1:
            test_frame.tuser = 1
        await tb.axis_source.send(test_frame)

    for k in range(3):
        rx_frame = await tb.rgmii_phy.tx.recv()

        if k == 1:
            assert rx_frame.error[-1] == 1
        else:
            assert rx_frame.get_payload() == test_data
            assert rx_frame.check_fcs()
            assert rx_frame.error is None

    assert tb.rgmii_phy.tx.empty()

    await RisingEdge(dut.tx_clk)
    await RisingEdge(dut.tx_clk)


def size_list():
    return list(range(60, 128)) + [512, 1514] + [60]*10


def incrementing_payload(length):
    return bytearray(itertools.islice(itertools.cycle(range(256)), length))


def cycle_en():
    return itertools.cycle([0, 0, 0, 1])


if cocotb.SIM_NAME:

    for test in [run_test_rx, run_test_tx]:

        factory = TestFactory(test)
        factory.add_option("payload_lengths", [size_list])
        factory.add_option("payload_data", [incrementing_payload])
        factory.add_option("ifg", [12])
        factory.add_option("speed", [1000e6, 100e6, 10e6])
        factory.generate_tests()

    for test in [run_test_tx_underrun, run_test_tx_error]:

        factory = TestFactory(test)
        factory.add_option("ifg", [12])
        factory.add_option("speed", [1000e6, 100e6, 10e6])
        factory.generate_tests()


# cocotb-test

tests_dir = os.path.abspath(os.path.dirname(__file__))
rtl_dir = os.path.abspath(os.path.join(tests_dir, '..', '..', 'rtl'))
lib_dir = os.path.abspath(os.path.join(rtl_dir, '..', '..', 'axis'))
axis_rtl_dir = os.path.abspath(os.path.join(lib_dir, 'rtl'))


def test_eth_mac_1g_rgmii(request):
    dut = "eth_mac_1g_rgmii"
    module = os.path.splitext(os.path.basename(__file__))[0]
    toplevel = dut

    verilog_sources = [
        os.path.join(rtl_dir, f"{dut}.v"),
        os.path.join(rtl_dir, "iddr.v"),
        os.path.join(rtl_dir, "oddr.v"),
        os.path.join(rtl_dir, "ssio_ddr_in.v"),
        os.path.join(rtl_dir, "rgmii_phy_if.v"),
        os.path.join(rtl_dir, "eth_mac_1g.v"),
        os.path.join(rtl_dir, "axis_gmii_rx.v"),
        os.path.join(rtl_dir, "axis_gmii_tx.v"),
        os.path.join(rtl_dir, "lfsr.v"),
    ]

    parameters = {}

    parameters['ENABLE_PADDING'] = 1
    parameters['MIN_FRAME_LENGTH'] = 64

    extra_env = {f'PARAM_{k}': str(v) for k, v in parameters.items()}

    sim_build = os.path.join(tests_dir, "sim_build",
        request.node.name.replace('[', '-').replace(']', ''))

    cocotb_test.simulator.run(
        python_search=[tests_dir],
        verilog_sources=verilog_sources,
        toplevel=toplevel,
        module=module,
        parameters=parameters,
        sim_build=sim_build,
        extra_env=extra_env,
    )
