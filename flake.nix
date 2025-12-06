{
  description = "Lenovo ThinkCentre Tiny Series Under-desk Mount";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        scadFile = ./thinkcenter_mount.scad;
      in
      {
        # Default package builds the STL for printing
        packages.default = pkgs.runCommand "mount-stl" {
          buildInputs = [ pkgs.openscad ];
        } ''
          mkdir -p $out
          # Generate the STL (uses default rotate_for_print=true from SCAD file)
          openscad -o $out/thinkcentre_mount.stl ${scadFile}
        '';

        devShells.default = pkgs.mkShell {
          buildInputs = [ pkgs.openscad ];
        };
      }
    );
}
