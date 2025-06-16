{
  description = "Nix derivations for smashy bros players.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      lib = nixpkgs.lib;
      pkgs = import nixpkgs { inherit system; };
      system = "x86_64-linux";
    in
    {
      packages.${system} = import ./pkgs { inherit lib pkgs; };
      formatter.${system} = pkgs.nixfmt-rfc-style;
      devShells.${system}.default = pkgs.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        buildInputs = with pkgs; [
          nixd
          nixfmt-rfc-style
        ];
      };
      checks.${system}.pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
        src = ./.;
        hooks = {
          nixfmt-rfc-style.enable = true;
        };
      };
    };
}
