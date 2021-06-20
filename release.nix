let
  pkgs = import <nixpkgs> { };
in
  pkgs.haskellPackages.callPackage ./naproche.nix { }
