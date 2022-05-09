{
  description = "Example ami flake";

  outputs = { self, nixpkgs }:
  let
    pkgs = import nixpkgs {
      system = "x86_64-linux";
    };
  in
  {
    ami = import ./ami.nix { inherit pkgs nixpkgs; };
  };
}
