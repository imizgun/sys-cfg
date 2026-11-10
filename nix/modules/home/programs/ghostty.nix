{ config, ... }:

let
  serviceName = "app-com.mitchellh.ghostty.service";
in
{
  programs.ghostty = {
    enable = true;

    # Installs Ghostty's D-Bus-activatable systemd user service: one
    # long-lived GTK process owns every window, so new windows don't pay
    # the GTK/GL startup cost again.
    systemd.enable = true;

    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-style = "SemiBold";

      # Always route `ghostty` launches (e.g. niri's Mod+T spawn) to the
      # running instance instead of only when started by a launcher/D-Bus.
      gtk-single-instance = true;
      # Keep the background instance alive after the last window closes,
      # otherwise the next window would cold-start GTK again.
      quit-after-last-window-closed = false;
    };
  };

  # The upstream unit has `WantedBy=graphical-session.target`; home-manager
  # only installs it, so add the wants-symlink to start it at login (warm
  # before the first Mod+T).
  xdg.configFile."systemd/user/graphical-session.target.wants/${serviceName}".source =
    config.xdg.configFile."systemd/user/${serviceName}".source;
}
