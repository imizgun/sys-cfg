{ pkgs, dotfiles, ... }:

{
  programs.niri.enable = true;
  programs.xwayland.enable = true;

  services.greetd.enable = true;
  services.greetd.settings.default_session.command =
    "${pkgs.tuigreet}/bin/tuigreet --remember --cmd niri-session";

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