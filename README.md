# MannaChip

More coming later, but for now:

```bash
nix-shell -I nixpkgs=channel:nixpkgs-25.05-darwin -p bluespec yosys-bluespec gnumake yosys nextpnr trellis openfpgaloader
# Generate Verilog
make verilog TOP_MODULE=mkTop
# Simulate
make sim TOP_MODULE=mkSim
./build/mkSim
make clean
# Program FPGA
make -C ulx3s_fpga/
```

# TODO
 - [ ] add nix flake
 - [ ] add instruction on how to use nix flake
