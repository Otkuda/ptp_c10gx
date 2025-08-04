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
    await Timer(CLK_PER*3, 'ns')

  async def load_offset(self, offset):
    self.dut.offset_nsec.value = offset << 8
    self.dut.offset_ld.value = 1
    await Timer(CLK_PER * 1, 'ns')
    self.dut.offset_ld.value = 0
    self.dut.offset_nsec.value = 0
    await Timer(CLK_PER * 1, 'ns')

  async def set_time(self, sec, nsec):
    self.dut.time_reg_ns_in.value = nsec
    self.dut.time_reg_sec_in.value = sec
    self.dut.time_ld.value = 1
    await Timer(CLK_PER, 'ns')
    self.dut.time_ld.value = 0
    self.dut.time_reg_ns_in.value = 0
    self.dut.time_reg_sec_in.value = 0
    

@cocotb.test()
async def basic_test(dut):
  tb = TB(dut)
  await tb.init()
  await Timer(CLK_PER, 'ns')
  await tb.load_period()
  await Timer(CLK_PER * 125, 'ns')
  assert int(tb.dut.time_ptp_ns.value) == CLK_PER * 125
  time_b = int(tb.dut.time_ptp_ns.value)
  await tb.load_offset(CLK_PER * 100)
  assert time_b + CLK_PER * (100 + 2) == int(tb.dut.time_ptp_ns.value)
  await Timer(100, 'ns')

@cocotb.test()
async def sec_test(dut):
  tb = TB(dut)
  await tb.init()
  await Timer(CLK_PER, 'ns')
  await tb.load_period()
  await Timer(CLK_PER*10, 'ns')
  await tb.set_time(0, (999950000<<8))
  await tb.load_offset(CLK_PER*100)
  await RisingEdge(tb.dut.time_one_pps)
  await Timer(100, 'ns')