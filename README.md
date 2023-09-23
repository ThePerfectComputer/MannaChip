# MannaChip

## Introduction:
Manna was the miraculous food provided by God requiring no effort on behalf of the Israelites. In a similar vein, the MannaChip processor delivers groundbreaking performance, necessitating minimal intervention on the developer's or user's part.

Just as "man does not live by bread alone, but by every word that proceeds from the mouth of God," this chip thrives on every instruction word you provide. It's not just about raw computational power, but the synergy between user input and hardware optimization.

``TOPMODULE=mkTop make v_compile`` to generate verilog. The generated verilog can
be found in the ``verilog_RTL/`` folder.

# Dependencies
You'll need to install:
1. [Yosys](https://github.com/YosysHQ/yosys) at git commit: 7ce5011c24b
2. [nextpnr-0.4-36-gc8406b71](https://github.com/YosysHQ/nextpnr)
3. [PrjTrellis](https://github.com/YosysHQ/prjtrellis) at git commit: 1.2.1-22-g35f5aff
4. [openFPGALoader](https://github.com/trabucayre/openFPGALoader)

# Programming the ULX3S
```bash
make prog
# You may need the following line to set your screen device config
# to one parity and one stop bit. Tested working on MacOS, should
# work on Linux.
stty -f /dev/tty.usbserial-K00027 -cstopb -parenb
screen /dev/tty.usbserial-K00027 9600
```

# Simulation
TODO

# Generating Verilog

```bash
TOPMODULE=mkTop make v_compile
```

# TODO
 - [ ] debug UART accuracy