{ pkgs, ... }:

let
  nautilus = "${pkgs.nautilus}/bin/nautilus";
in
{
  # One long-lived GTK process owns every Nautilus window, started with the
  # graphical session, so Mod+E (`spawn "nautilus"`) just asks the running
  # instance over D-Bus for a new window instead of cold-starting GTK.
  systemd.user.services.nautilus = {
    Unit = {
      Description = "Nautilus file manager (background instance)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "dbus";
      BusName = "org.gnome.Nautilus";
      ExecStart = "${nautilus} --gapplication-service";
      # `--gapplication-service` alone exits after ~10s with no windows
      # (GApplication inactivity timeout). Nautilus' main() calls
      # g_application_hold() when this is set, keeping it resident — the
      # equivalent of Ghostty's quit-after-last-window-closed = false.
      Environment = [ "NAUTILUS_PERSIST=1" ];
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Override the package's D-Bus activation files (same names, higher
  # priority in XDG_DATA_HOME) so activation by the portal / FileManager1
  # callers goes through the systemd unit above — getting NAUTILUS_PERSIST —
  # rather than spawning a separate, short-lived instance.
  xdg.dataFile = {
    "dbus-1/services/org.gnome.Nautilus.service".text = ''
      [D-BUS Service]
      Name=org.gnome.Nautilus
      Exec=${nautilus} --gapplication-service
      SystemdService=nautilus.service
    '';
    "dbus-1/services/org.freedesktop.FileManager1.service".text = ''
      [D-BUS Service]
      Name=org.freedesktop.FileManager1
      Exec=${nautilus} --gapplication-service
      SystemdService=nautilus.service
    '';
  };
}
