{
  pkgs,
  inputs,
  ...
}: let
  nixpkgs = inputs.nixpkgs;
in {
  imports = [
    "${nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
    "${nixpkgs}/nixos/modules/profiles/headless.nix"
  ];
  users.users.esk = {
    isNormalUser = true;
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDMdxqFTG7bPey17ZWg6LbonqASSNJnlmdMg3yiYPuNu6/b4Ffe4iycGAwVl/ODKnEzLZ2aWUhiVrLMv4Z6vml3/l/qU3PPeQRe+TY0afXLbT05xDG2HS/y5SE/6qoynKb2FzJ8YCpI3xdoJ3E4L5+a5vZ1yjknaFcHcL0/g5GCsKo0QpO6dH9Tz+W36Ua/kGXmqMzDaOraXLvTc2TBJ4Mm/CRy6zL773V4GE5e+w4MxdYGpaGZ2EaKw37xFAyx2lH2/RbRt+qTsvGOjfhXuMyOEtsrDEkM7mbRdjuC8WzlutTrDESRJuVAu47HEZjMKCaQ05wgI/LYS3CeolorGDf9tahnjS5s0x7X+NIRkEA0qgpxUwr5T9Z7JKWIIOV90Rbu6CFEfhldNtfA5uD8RLufIiiQTsTZmHjHaPWi98iphb+wMpy8yB4lPPzoWfSuofPVcWaLFoFzGwKkP38XLyeKXEyUgGJPTLPLkGNjQgTBqZlOTL06UR8GNKPtWo5dMCvsFuz0+u34LaeyNg+2i7gvhWZakDZ1EAqWdtj6A+8oAlIEa04OR09xlfdjA9BMA4xGyq9sOKn99tV5qTIZl3X+MIxxPUm0TYXulM4kByeKROAvQhgwSUJAE63qVddBnl+PAsUZPREl8l/ccuytZIlnDn2RY0LlIXGYb0tIEykSqw=="
    ];
    extraGroups = ["wheel" "docker"];
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    autoResize = true;
  };
  boot.loader.grub.device = "/dev/vda";
  boot.loader.timeout = 0;
  networking.enableIPv6 = false;

  environment.systemPackages = with pkgs; [
    wget
    neovim
    linuxPackages.perf
    git
    htop
    tig
  ];

  services.openssh = {
    enable = true;
    permitRootLogin = "prohibit-password";
    passwordAuthentication = false;
  };

  systemd.network = {
    networks = {
      "70-unmanaged" = {
        matchConfig.Name = "veth* cni* flannel*";
        linkConfig.Unmanaged = true;
      };
      "99-nov6" = {
        matchConfig.Name = "*";
        extraConfig = ''
          IPv6AcceptRA=no
        '';
      };
    };
  };
  networking.useDHCP = false;
  networking.useNetworkd = true;
  # network interfaces specifically configured for my libvirt setup
  networking.interfaces.ens2.useDHCP = true;
  networking.interfaces.ens3.useDHCP = true;

  networking.hostName = "repro";
  security.sudo.extraRules = [
    {
      users = ["esk"];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];

  networking.firewall.allowedTCPPorts = [22];
  networking.firewall.trustedInterfaces = ["ens3" "cni0" "flannel.1" "wg0" "flannel-wg" "flannel-wg-v6"];

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "50000";
    }
  ];
}
