{ dotfiles, ... }:

let
  serviceName = "app-com.mitchellh.ghostty.service";
in
{
  # A function module: `config` here is Home Manager's, not the system's.
  hm = { config, ... }: {
    programs.ghostty = {
      enable = true;

      # Installs Ghostty's D-Bus-activatable systemd user service: one
      # long-lived GTK process owns every window, so new windows don't pay
      # the GTK/GL startup cost again.
      systemd.enable = true;
    };

    xdg.configFile."ghostty/config.ghostty".source = "${dotfiles}/ghostty/config.ghostty";

    # The upstream unit has `WantedBy=graphical-session.target`; home-manager
    # only installs it, so add the wants-symlink to start it at login (warm
    # before the first Mod+T).
    xdg.configFile."systemd/user/graphical-session.target.wants/${serviceName}".source =
      config.xdg.configFile."systemd/user/${serviceName}".source;
  };
}
