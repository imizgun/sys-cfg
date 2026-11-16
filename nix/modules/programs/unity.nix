{ pkgs, ... }:

# PC only (hosts/nixos). Unity Hub from nixpkgs: an FHS env, so editors the
# Hub downloads into ~/Unity/Hub/Editor run unpatched. Install editor
# versions through the Hub itself, not nix.
#
# The editor is X11-only on Linux, so under niri it runs through
# xwayland-satellite (desktop/niri.nix).
#
# Rider (packages/dev.nix) isn't auto-detected at a NixOS path: set it in
# Unity → Preferences → External Tools → Browse →
# /etc/profiles/per-user/<user>/bin/rider, with com.unity.ide.rider in the
# project.
{
  hm.home.packages = [
    (pkgs.unityhub.override {
      # Add here what an editor version complains is missing:
      # extraPkgs = for binaries, extraLibs = for shared libraries.
      extraLibs = _: [ ];
    })
  ];

  # Same story as programs/steam.nix: niri sets GDK_SCALE=2 session-wide
  # (dotfiles/niri/cfg/misc.kdl), but the PC's monitor is 1x, so the Hub and
  # the editors it launches (they inherit its env) render 2x too big.
  # Shadows the package's own unityhub.desktop.
  hm.xdg.desktopEntries.unityhub = {
    name = "Unity Hub";
    comment = "The Official Unity Hub";
    exec = "env GDK_SCALE=1 unityhub %U";
    icon = "unityhub";
    terminal = false;
    categories = [ "Development" ];
    mimeType = [ "x-scheme-handler/unityhub" ];
  };
}
