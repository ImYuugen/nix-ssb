{ lib, pkgs }:

{
  slippi-launcher = pkgs.callPackage ./slippi-launcher.nix { };
  slippi-netplay = pkgs.callPackage ./slippi-netplay.nix { };
}
