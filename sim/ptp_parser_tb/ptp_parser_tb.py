from scapy.all import *

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, ClockCycles, FallingEdge
import cocotb.utils

from cocotbext.eth import GmiiSource, GmiiFrame

from fw.tools.ptp_sender import myieee1588

CLK_PER = 8

class RtcTimer():
  
  def __init__(self, dut):
    self.dut = dut
    self.sec = 0
    self.nsec = 0

  async def start_count(self):
    while True:
      await RisingEdge(self.dut.rtc_timer_clk)
      self.nsec += CLK_PER
      if (self.nsec >= 1e9):
        self.sec += 1
        self.nsec -= 1e9
      self.dut.rtc_timer_in.value = int(self.sec * 1e9 + self.nsec) 

class TB():

  def __init__(self, dut):
    self.dut = dut

    dut.rtc_timer_clk.setimmediatevalue(0)
    dut.rst.setimmediatevalue(0)

    cocotb.start_soon(Clock(dut.rtc_timer_clk, CLK_PER, 'ns').start())
    cocotb.start_soon(Clock(dut.gmii_clk, CLK_PER, 'ns').start())
    self.gmii_tx = GmiiSource(dut.gmii_data, None, dut.gmii_ctrl, dut.gmii_clk)
    self.dut.giga_mode.value = 1
    self.dut.ptp_msgid_mask = 0xff

  async def reset(self):
    self.dut.rst.value = 1
    await Timer(CLK_PER * 2, 'ns')

    self.dut.rst.value = 0

  async def init(self):
    await self.reset()
    cocotb.start_soon(RtcTimer(self.dut).start_count())

@cocotb.test()
async def test_parser(dut):
  tb = TB(dut)
  pkt = Ether(src="02:00:00:00:00:00", dst="12:34:56:78:90:aa") / myieee1588()
  await tb.init()
  await Timer(200, 'ns')
  frame = GmiiFrame.from_payload(raw(pkt))
  await tb.gmii_tx.send(frame)

  await Timer(1000, 'ns')
