{ ... }:

{
  imports = [
    # programs: declaratively-configured CLI tools
    ./programs/fish.nix
    ./programs/kitty.nix
    ./programs/helix.nix
    ./programs/direnv.nix

    # desktop: the graphical session
    ./desktop/niri.nix
    ./desktop/steam.nix
    ./desktop/font.nix

    # theme: appearance, shared across GTK/niri/cursor
    ./theme/cursor.nix
    ./theme/gtk.nix

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
