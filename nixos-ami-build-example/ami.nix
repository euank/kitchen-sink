{ nixpkgs, pkgs }:
((import "${nixpkgs}/nixos/release.nix") {
  configuration = { config, ... }: {
    amazonImage = {
      # raw format so we can upload it directly with coldsnap instead of going
      # through the vm import/export service.
      # In theory, it should be faster to upload a compressed vmdk and have
      # amazon deal with spitting out a snapshot on their end (less network
      # bandwidth).
      # In practice, uploading a 16 gig raw file that's mostly 0 bytes seems
      # quicker. Go figure.
      format = "raw";
      sizeMB = 16 * 1024;
    };

    environment.systemPackages = with pkgs; [
      curl git vim
    ];

    users.users.esk = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };

    # other desired config
  };
}).amazonImage.x86_64-linux
