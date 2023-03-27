{
  inputs.nixpkgs.url = "github:euank/nixpkgs/test-anki-wayland";

  outputs = { self, nixpkgs, ... }@input:
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
          # I needed this for sway to launch in my qemu
          virtualisation.qemu.options = ["-vga none" "-device virtio-vga-gl" "-display sdl,gl=on"];
          virtualisation.vmVariant.virtualisation.graphics = true;

          services.dbus.enable = true;
          xdg.portal = {
            enable = true;
            wlr.enable = true;
          };
          services.qemuGuest.enable = true;
          boot.plymouth.enable = true;

          fileSystems."/".device = "/dev/disk/by-label/nixos";
          boot.loader.grub.device = "/dev/vda";
          system.stateVersion = "20.03";

          environment.systemPackages = with pkgs; [
            anki
          ];

          users.users.test = {
            isNormalUser = true;
            initialPassword = "password";
            extraGroups = [ "wheel" "sway" ];
          };

          programs.sway = {
            enable = true;
            wrapperFeatures.gtk = true;
            extraPackages = with pkgs; [
              foot
              dmenu
            ];
          };
          programs.waybar.enable = true;
        })
      ];
    };
  };
}
