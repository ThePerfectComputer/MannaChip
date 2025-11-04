{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs =
    inputs:
    inputs.utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import inputs.nixpkgs {
          localSystem = system;
          overlays = [
            (_: _: {

              MannaChip = pkgs.callPackage (
                {
                  stdenv,
                  bluespec,
                  nextpnr,
                  openfpgaloader,
                  trellis,
                  which,
                  yosys,
                }:
                stdenv.mkDerivation {
                  pname = "MannaChip";
                  version = "0.1.0";
                  src = inputs.self;

                  strictDeps = true;
                  nativeBuildInputs = [
                    bluespec
                    nextpnr
                    openfpgaloader
                    trellis
                    which
                    yosys
                  ];

                  buildPhase = ''
                    runHook postBuild

                    make -C ulx3s_fpga mkTop.bit
                    # TODO: what else to build?

                    runHook postBuild
                  '';

                  installPhase = ''
                    runHook preInstall

                    mkdir -p "$out"
                    cp "./ulx3s_fpga/mkTop.bit" "$out/"
                    # TODO: what else to install?

                    runHook postInstall
                  '';

                }
              ) { };

            })
          ];
        };
      in
      {
        packages = {
          default = inputs.self.packages."${system}".MannaChip;
          MannaChip = pkgs.MannaChip;
        };

        devShells.default =
          with pkgs;
          mkShell {
            inputsFrom = [ MannaChip ];
          };

        formatter = pkgs.nixfmt-tree;
      }
    );
}
