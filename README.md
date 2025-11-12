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
 - [ ] confirm (TLog 5) evaluates to 3 and (TLog 4) evaluates to 2 etc
 - [ ] address shadowing warnings in `Top.bs`
 - [ ] work on creating response assembler
 - [ ] `currentTransactionTag` should be guarded
