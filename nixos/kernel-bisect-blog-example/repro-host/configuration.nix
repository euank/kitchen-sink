{
  pkgs,
  inputs,
  ...
}: let
  nixpkgs = inputs.nixpkgs;

  commit = "45100eec5f682b606e35ab0567417bf611821a60";
  kernel = pkgs.linuxPackages_custom {
    src = builtins.fetchTarball {
      url = "https://github.com/torvalds/linux/archive/${commit}.tar.gz";
      sha256 = "1lhf4kgpqmbbf57n1ibwwha8kpw7kfqwhmk5rk1d40036x9d9a58";
    };
    version = "4.12.5";
    configfile = ./kconfig;
  };

in {
  # Note, in the real one we have actual hardware imports here, but for the
  # sake of example, I'm sticking to this.
  imports = [
    "${nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
    "${nixpkgs}/nixos/modules/profiles/headless.nix"
  ];
  boot.kernelPackages = kernel;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.timeout = 0;

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

  environment.systemPackages = with pkgs; [
    wget
    neovim
    linuxPackages.perf
    git
    htop
    tig
    virt-manager
  ];

  services.openssh = {
    enable = true;
    permitRootLogin = "prohibit-password";
    passwordAuthentication = false;
  };

  virtualisation.libvirtd.enable = true;

  networking.useDHCP = false;
  # network interfaces specifically configured for my libvirt setup
  networking.interfaces.ens2.useDHCP = true;

  networking.hostName = "repro-host";
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

  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "50000";
    }
  ];
}
