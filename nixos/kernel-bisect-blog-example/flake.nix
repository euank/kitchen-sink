{
  description = "an example flake used for a blogpost";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-21.11";
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
    evalConfig = import "${nixpkgs}/nixos/lib/eval-config.nix";
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
    qemuImage = (import "${nixpkgs}/nixos/lib/make-disk-image.nix") {
      pkgs = pkgs;
      lib = pkgs.lib;

      diskSize = 8 * 1024;
      format = "qcow2";
      copyChannel = false;

      config =
        (evalConfig {
          inherit system;
          modules = [
            (import ./repro/configuration.nix {inherit pkgs inputs;})
          ];
        })
        .config;
    };
  };
}
