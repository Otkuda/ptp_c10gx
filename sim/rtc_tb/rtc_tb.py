from scapy.all import *

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer, RisingEdge, ClockCycles, FallingEdge
import cocotb.utils

CLK_PER = 8

class TB():

  def __init__(self, dut):
    self.dut = dut
    dut.clk.setimmediatevalue(0)
    dut.rst.setimmediatevalue(0)
    dut.time_ld.setimmediatevalue(0)
    cocotb.start_soon(Clock(dut.clk, CLK_PER, 'ns').start())
    
  async def reset(self):
    self.dut.rst.value = 1
    await Timer(CLK_PER * 2, 'ns')

    self.dut.rst.value = 0

  async def init(self):
    await self.reset()

  async def load_period(self, period=CLK_PER):
    self.dut.period_in.value = period << 32
    self.dut.period_ld.value = 1
    await Timer(CLK_PER * 1, 'ns')
    self.dut.period_ld.value = 0
    self.dut.period_in.value = 0

  async def load_offset(self, offset):
    self.dut.offset_nsec.value = offset << 8
    self.dut.offset_ld.value = 1
    await Timer(CLK_PER * 1, 'ns')
    self.dut.offset_ld.value = 0
    self.dut.offset_nsec.value = 0

@cocotb.test()
async def test_parser(dut):
  tb = TB(dut)
  await tb.init()
  await Timer(CLK_PER, 'ns')
  await tb.load_period()
  await Timer(1000, 'ns')
  await tb.load_offset(CLK_PER * 100)
  await Timer(100, 'ns')