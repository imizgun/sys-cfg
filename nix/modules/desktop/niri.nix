{ pkgs, dotfiles, hostname, ... }:

let
  # ly's colormix palette per host. Format 0xSSRRGGBB,
  # SS = termbox styling byte (00 = plain color).
  # The PC is `nixos` here (`mainpc` only in dotfiles/).
  lyColors =
    if hostname == "nixos" then {
      colormix_col1 = "0x0014B8A6"; # teal
      colormix_col2 = "0x0010B981"; # emerald
      colormix_col3 = "0x00042F2E"; # deep teal
    } else {
      colormix_col1 = "0x005E81AC";
      colormix_col2 = "0x00B48EAD";
      colormix_col3 = "0x002E3440";
    };
in
{
  programs.niri.enable = true;
  programs.xwayland.enable = true;

  # TUI display manager; niri shows up via programs.niri's wayland session.
  # Remembers the last user/session by default (save = true).
  services.displayManager.ly = {
    enable = true;
    settings = {
      animation = "colormix";
    } // lyColors;
  };

  # Required for Home Manager's gtk.colorScheme/theme/iconTheme
  # (theme/gtk.nix) to actually reach GTK/libadwaita apps like Nautilus —
  # without this you get a systemd activation error instead of a themed
  # desktop.
  programs.dconf.enable = true;

  hm.home.packages = [ pkgs.xwayland-satellite ];

  # Source of truth is dotfiles/niri in this same repo — edit it and
  # rebuild to pick up changes. Symlinking the whole directory (not just
  # config.kdl) keeps the `include "./cfg/*.kdl"` relative paths inside
  # config.kdl working.
  hm.xdg.configFile."niri" = {
    source = "${dotfiles}/niri";
    recursive = true;
  };
}