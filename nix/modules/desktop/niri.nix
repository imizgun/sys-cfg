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

  # The session environment lives here rather than in dotfiles/niri/cfg,
  # because GDK_SCALE has to differ per host and KDL has no notion of one.
  # Lands next to the symlinked dotfiles: xdg.configFile."niri" is recursive,
  # so ~/.config/niri/cfg is a real directory of per-file symlinks.
  #
  # GDK_SCALE only takes integers and applies to the whole session, while
  # X11/XWayland has no per-output scale: GTK apps (and OpenJDK, which
  # derives sun.java2d.uiScale from it) get this one number regardless of
  # which monitor they open on. 2 is for the laptop's eDP-1 at scale 1.75;
  # the PC's HDMI-A-1 is 1x, and forcing 2 there made every X11 app render
  # twice too large — with doubled minimum-size hints, so niri could not
  # shrink them either. That used to be patched per application; keep it
  # correct here instead.
  hm.xdg.configFile."niri/cfg/env.kdl".text = ''
    environment {
        _JAVA_AWT_WM_NONREPARENTING "1"
        GDK_SCALE "${if hostname == "laptop" then "2" else "1"}"
        XCURSOR_SIZE "24"
        ELECTRON_OZONE_PLATFORM_HINT "auto"
        QT_QPA_PLATFORM "wayland"
        QT_QPA_PLATFORMTHEME "gtk3"
        QT_WAYLAND_DISABLE_WINDOWDECORATION "1"
        XDG_CURRENT_DESKTOP "niri"
        XDG_SESSION_TYPE "wayland"
    }
  '';
}