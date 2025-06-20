{ lib, pkgs }:

rec {
  slippi-launcher = pkgs.callPackage ./slippi-launcher.nix { };
  slippi-launcher-source = pkgs.callPackage ./slippi-launcher { inherit slippi-netplay; };
  slippi-netplay = pkgs.callPackage ./slippi-netplay.nix { };
}
