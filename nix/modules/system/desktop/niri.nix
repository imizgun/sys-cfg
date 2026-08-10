{ pkgs, ... }:

{
  programs.niri.enable = true;

  services.greetd.enable = true;
  services.greetd.settings.default_session.command =
    "${pkgs.tuigreet}/bin/tuigreet --remember --cmd niri-session";

  # Required for Home Manager's gtk.colorScheme/theme/iconTheme
  # (modules/home/theme/gtk.nix) to actually reach GTK/libadwaita apps
  # like Nautilus — without this you get a systemd activation error
  # instead of a themed desktop.
  programs.dconf.enable = true;
}
