{ pkgs, ... }:

{
  # niri/cfg/misc.kdl points at xcursor-theme "capitaine-cursors" but nothing
  # ever installed that theme, so niri fell back to an oversized default
  # cursor. This installs it and keeps GTK/Qt/X11 apps consistent with it too.
  home.pointerCursor = {
    enable = true;
    package = pkgs.capitaine-cursors;
    name = "capitaine-cursors";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
}
