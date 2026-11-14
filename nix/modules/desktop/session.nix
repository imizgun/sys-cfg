{ ... }:

{
  # Duplicates niri's `environment { ELECTRON_OZONE_PLATFORM_HINT }` (see
  # dotfiles/niri/cfg/misc.kdl) at the session/login level, since niri
  # only applies that block to processes it spawns directly. Apps launched
  # via systemd/dbus activation (e.g. the noctalia launcher) otherwise miss
  # it, which breaks Electron apps' Wayland screen capture (e.g. Discord
  # screen share crashing when launched from the app launcher but not from
  # a niri-spawned terminal).
  hm.home.sessionVariables = {
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };
}
