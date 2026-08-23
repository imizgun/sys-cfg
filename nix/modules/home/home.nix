{ username, ... }:

{
  imports = [
    # programs: declaratively-configured CLI tools
    ./programs/fish.nix
    ./programs/kitty.nix
    ./programs/helix.nix
    ./programs/direnv.nix

    # desktop: the graphical session
    ./desktop/niri.nix
    ./desktop/noctalia.nix
    ./desktop/steam.nix
    ./desktop/font.nix

    # theme: appearance, shared across GTK/niri/cursor
    ./theme/cursor.nix
    ./theme/gtk.nix

    ./packages.nix
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";

  # Matches system.stateVersion in hosts/nixos/configuration.nix — do not
  # bump this on new NixOS releases, it just pins Home Manager's own
  # defaults to what this profile was created with.
  home.stateVersion = "26.05";

  # Duplicates niri's `environment { ELECTRON_OZONE_PLATFORM_HINT }` (see
  # niri-dotfiles/niri/cfg/misc.kdl) at the session/login level, since niri
  # only applies that block to processes it spawns directly. Apps launched
  # via systemd/dbus activation (e.g. the noctalia launcher) otherwise miss
  # it, which breaks Electron apps' Wayland screen capture (e.g. Discord
  # screen share crashing when launched from the app launcher but not from
  # a niri-spawned terminal).
  home.sessionVariables = {
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  programs.home-manager.enable = true;
}
