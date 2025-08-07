# Precision Time Protocol on Intel Cyclone 10 GX DevBoard

**Work in Progress**

## Used cores and libraries

[Verilog Ethernet stack by Alex Forencich](https://github.com/alexforencich/verilog-ethernet)

[i2c cores by Alex Forencich](https://github.com/alexforencich/verilog-i2c)

[Hardware Assisted IEEE1588](https://github.com/freecores/ha1588). Includes RTC and TSU.

[PicoRV32](https://github.com/YosysHQ/picorv32)

## Features

- Implementation of PTPv2 slave in E2E configuration;
- Synchronization accuracy up to 7 μs; *(work in progress)*
- Calculation of offset and rtt;
- Direct time adjustment;
- Precise time adjustment with PI-regulator; *(work in progress)*
- No BMC algorithm. **(not planned)**

## Purpose

This project was created as part of bachelors thesis for St. Petersburg Polytechnic Univercity.
When testing on board, it was connected to [White Rabbit](https://white-rabbit.web.cern.ch/) Switch, which regularly sends PTP packets.
Announce messages are ignored.

...
