let
  inherit (import <nixpkgs> {}) fetchFromGitHub;
  nixpkgs = fetchFromGitHub {
    owner  = "NixOS";
    repo   = "nixpkgs-channels";
    rev    = "502845c3e31ef3de0e424f3fcb09217df2ce6df6";
    sha256 = "0fcqpsy6y7dgn0y0wgpa56gsg0b0p8avlpjrd79fp4mp9bl18nda";
  };
  pkgs = import nixpkgs {};
  shellname = "FIXME";
in
  pkgs.stdenv.mkDerivation {
    name = shellname;
    buildInputs = [
      pkgs.bashInteractive
      pkgs.entr
      pkgs.ripgrep
      pkgs.fd
      pkgs.sd

      # JavaScript
      pkgs.nodejs
      pkgs.yarn

      # Elixir
      pkgs.elixir

      # Go
      pkgs.go

      # Crystal
      pkgs.crystal
      pkgs.shards

      # Nim
      pkgs.nim

      # C/C++
      pkgs.gcc
      pkgs.clang

      # Zig
      pkgs.zig

      # Rust
      pkgs.cargo
      pkgs.rustc

      # Haskell
      pkgs.ghc
      pkgs.stack
      pkgs.ormolu

      # Scala
      pkgs.scala
      pkgs.ammonite
      pkgs.sbt
      pkgs.mill
    ];
    shellHook = ''
      export NIX_SHELL_NAME='${shellname}'
    '';
  }
