{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/d34a98666913267786d9ab4aa803a1fc75f81f4d.tar.gz") {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.yosys
    pkgs.nextpnr
    pkgs.bluespec
    pkgs.yosys-bluespec
  ];

  shellHook = ''
    echo "Dev environment for Manna Chip."
  '';
}