{ ... }:

{
  imports = [
    ./fish.nix
    ./kitty.nix
    ./helix.nix
    ./niri.nix
    ./packages.nix
  ];

  home.username = "vkabaczko";
  home.homeDirectory = "/home/vkabaczko";

  # Matches system.stateVersion in hosts/nixos/configuration.nix — do not
  # bump this on new NixOS releases, it just pins Home Manager's own
  # defaults to what this profile was created with.
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
