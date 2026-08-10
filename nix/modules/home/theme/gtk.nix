{ pkgs, ... }:

{
  # Nautilus is GTK4/libadwaita — it mostly ignores custom widget themes
  # and instead follows colorScheme (via dconf, wired through
  # modules/system/desktop/niri.nix's programs.dconf.enable) and
  # iconTheme. The system had *no* icon theme installed before this
  # (only the hicolor/locolor fallback), which is why everything looked
  # bare — that's the actual fix here, adw-gtk3 is just for GTK3 apps to
  # match the same libadwaita look.
  gtk = {
    enable = true;

    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };

    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };

    colorScheme = "dark";
  };
}
