{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
  in
  {
    nixosConfigurations.test = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
        ({...}: {
          virtualisation.vmVariant.virtualisation.graphics = true;

          services.dbus.enable = true;
          services.xserver = {
            layout = "test";
            extraLayouts.test = {
              description = "test";
              languages = [ "eng" ];
              symbolsFile = "${pkgs.xkeyboard_config}/share/X11/xkb/symbols/us";
            };
          };
          services.qemuGuest.enable = true;
          boot.plymouth.enable = true;

          fileSystems."/".device = "/dev/disk/by-label/nixos";
          boot.loader.grub.device = "/dev/vda";
          system.stateVersion = "20.03";

          environment.systemPackages = with pkgs; [
            calibre
          ];

          users.users.test = {
            isNormalUser = true;
            initialPassword = "password";
            extraGroups = [ "wheel" "sway" ];
          };

          services.xserver.enable  = true;
          services.xserver.desktopManager.xfce.enable  = true;
          services.xserver.displayManager.autoLogin = {
            enable = true;
            user = "test";
          };
        })
      ];
    };
  };
}
