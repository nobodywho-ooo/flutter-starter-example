{
  description = "NobodyWho Flutter Starter Example";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # nobodywho.url = "github:nobodywho-ooo/nobodywho";
    nobodywho.url = "github:nobodywho-ooo/nobodywho/feat/model-downloading";
    # nobodywho.url = "/home/asbjorn/Development/am/nobodywho-rs";
    # nobodywho.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      nobodywho,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        nobodywho_flutter_rust = nobodywho.packages.${system}.flutter_rust;
      in
      {
        packages.default = pkgs.callPackage ./default.nix {
          inherit nobodywho_flutter_rust;
        };
      }
    );
}
