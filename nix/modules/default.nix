# Modules every host gets. Host-only ones are imported in hosts/<name>/default.nix.
#
# Each file is a NixOS module for one feature, system and user side together:
# system options at the top level, Home Manager options under `hm.*`
# (an alias for home-manager.users.<username>, see core/home.nix).
{
  imports = [
    # core: boots, networks, and identifies the machine
    ./core/nix.nix
    ./core/home.nix
    ./core/boot.nix
    ./core/locale.nix
    ./core/networking.nix
    ./core/users.nix

    # hardware: device-level enablement
    ./hardware/audio.nix
    ./hardware/bluetooth.nix
    ./hardware/power.nix
    ./hardware/storage.nix
    ./hardware/snapshots.nix
    ./hardware/udev.nix
    ./hardware/virt.nix

    # desktop: the graphical session
    ./desktop/session.nix
    ./desktop/niri.nix
    ./desktop/noctalia.nix
    ./desktop/fonts.nix

    # programs: tools with their own config
    ./programs/fish.nix
    ./programs/ghostty.nix
    ./programs/nautilus.nix
    ./programs/helix.nix
    ./programs/direnv.nix
    ./programs/jdk.nix
    ./programs/kitty.nix
    ./programs/vicinae.nix
    ./programs/steam.nix

    # theme: appearance, shared across GTK/niri/cursor
    ./theme/gtk.nix
    ./theme/cursor.nix

    # packages: plain package lists
    ./packages/base.nix
    ./packages/browsers.nix
    ./packages/dev.nix
    ./packages/apps.nix
  ];
}
