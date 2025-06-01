import cocotb
from cocotb.runner import get_runner

import os
from pathlib import Path

def test_runner():
    src = Path("./rtl/ptp")

    sim = os.getenv("SIM", "questa")
    build_dir = Path("ptp_parser")
    build_dir.mkdir(exist_ok=True)

    verilog_sources = [
        src / "ptp_parser.v",
        "./sim/ptp_parser_tb/tsu_sim.v"
    ]

    hdl_toplevel = "tsu_sim"
    test_module = "ptp_parser_tb"

    runner = get_runner(sim)

    runner.build(
        verilog_sources=verilog_sources,
        hdl_toplevel=hdl_toplevel,
        build_dir=build_dir,
        always=True
    )
    
    runner.test(
        hdl_toplevel=hdl_toplevel,
        test_module=test_module,
        waves=True,
        gui=True,
        # pre_cmd=['do ../wave.do']
    )
