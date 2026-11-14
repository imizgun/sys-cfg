{ inputs, username, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;

  nixpkgs.config.allowUnfree = true;
  # Package fixes, own packages (pkgs/), `pkgs.master` — see overlays/default.nix.
  nixpkgs.overlays = import ../../overlays { inherit inputs; };

  # Lets generic dynamically-linked Linux binaries run unmodified (e.g. Zed's
  # auto-downloaded rust-analyzer, rustup toolchains) instead of failing with
  # "cannot execute: required file not found".
  programs.nix-ld.enable = true;

  # nh: nicer nixos-rebuild (diff of what changes, progress tree, confirm).
  #   nh os switch            build + activate (NH_FLAKE points at this repo)
  #   nh os switch --update   nix flake update first
  #   nh os test / boot       activate without a boot entry / only on reboot
  #   nh search <name>        search nixpkgs
  programs.nh = {
    enable = true;
    flake = "/home/${username}/sys-cfg/nix";
    # Replaces nix.gc: removes old generations + garbage weekly, but keeps the
    # last 5 generations whatever their age (nix.gc kept only "< 14 days").
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep-since 14d --keep 5";
    };
  };
}
