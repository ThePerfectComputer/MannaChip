# MannaChip

## Introduction:
Manna was the miraculous food provided by God requiring no effort on behalf of the Israelites. In a similar vein, the POWER3.0 compliant MannaChip 
processor delivers groundbreaking performance, necessitating minimal intervention on the developer's or user's part.

Just as "man does not live by bread alone, but by every word that proceeds from the mouth of God," this chip thrives on every instruction word you provide. It's not just about raw computational power, but the synergy between user input and hardware optimization.

``TOPMODULE=mkTop make v_compile`` to generate verilog. The generated verilog can
be found in the ``verilog_RTL/`` folder.

# Status
Admittedly, not very far. Perhaps one could say we've got the beginnings 
of what would make for LED and UART controllers.

# Dependencies
## Linux
Running `nix-shell` should *just work* on Linux. To be fair, haven't
tested this yet.

## MacOS
Upstream nix recipes need to be adjusted a bit to work on MacOS, so
for now do:
1. [Yosys](https://github.com/YosysHQ/yosys) at git commit: 7ce5011c24b
2. [nextpnr-0.4-36-gc8406b71](https://github.com/YosysHQ/nextpnr)
3. [PrjTrellis](https://github.com/YosysHQ/prjtrellis) at git commit: 1.2.1-22-g35f5aff
4. [openFPGALoader](https://github.com/trabucayre/openFPGALoader)

# Programming the ULX3S
```bash
make fpga
# You may need the following line to set your screen device config
# to one parity and one stop bit. Tested working on MacOS, should
# work on Linux.
stty -f /dev/tty.usbserial-K00027 -cstopb -parenb
screen /dev/tty.usbserial-K00027 9600
```

# Simulation
## Main Chip Core
The following command will simulate the UART loopback
by having the bluespec sources call some C code that
commandeers the tty, disables echo, exposes the tty write
buffer to bluespec(what the user types), and exposes
a buffer bluespec can use to write to terminal.

```bash
TOPMODULE=mkSim make b_all
```

## Experiments
See experiments README.

# Generating Verilog
```bash
TOPMODULE=mkTop make v_compile
```

# TODO
 - [ ] debug UART accuracy
       - clk divider should be frequency matched
 - [ ] move to JoyOfHardware
 - [ ] port in [PPC_Formal](https://github.com/JoyOfHardware/PPC_Formal)
      - [ ] create I and D caches
      - [ ] try to optimize decoder

# Notable Reference Files
``/Users/yehowshuaimmanuel/git/bsc/testsuite/bsc.bsv_examples/cpu/FiveStageCPUQ3sol.bsv``