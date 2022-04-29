{
  description = "an example flake used for a blogpost";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
  in {
    nixosConfigurations = rec {
      # thinned down repro
      # On a machine, `nixos-rebuild --switch '.#repro'` reproduces with this configuration
      repro = nixpkgs.lib.nixosSystem rec {
        inherit pkgs;
        specialArgs = {inherit inputs;};
        system = "x86_64-linux";
        modules = [
          ./repro/configuration.nix
        ];
      };
    };
  };
}
