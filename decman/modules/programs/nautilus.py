from decman.plugins import pacman, systemd

from lib import SysModule, user_file


class Nautilus(SysModule):
    """Nautilus as one resident instance started with the session; the D-Bus
    service overrides route activation through that unit. Details in the files."""

    NAME = "programs.nautilus"

    def files(self):
        h = self.host
        return (
            user_file(h, "systemd/user/nautilus.service", ".config/systemd/user/nautilus.service")
            | user_file(h, "dbus-1/services/org.gnome.Nautilus.service",
                        ".local/share/dbus-1/services/org.gnome.Nautilus.service")
            | user_file(h, "dbus-1/services/org.freedesktop.FileManager1.service",
                        ".local/share/dbus-1/services/org.freedesktop.FileManager1.service")
        )

    @pacman.packages
    def pacman_packages(self):
        return {"nautilus"}

    @systemd.user_units
    def user_units(self):
        return {self.host.username: {"nautilus.service"}}


def module(host):
    return Nautilus(host)
