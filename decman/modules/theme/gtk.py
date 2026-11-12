import decman
from decman.plugins import pacman

from lib import SysModule, etc_file, link


class Gtk(SysModule):
    """Dark libadwaita look: settings.ini for GTK3/4, gtkrc for GTK2, and a
    system dconf db for color-scheme (what GTK4/libadwaita apps actually read;
    a system db needs no running session, unlike `gsettings set`)."""


    def files(self):
        return (
            etc_file("/etc/dconf/profile/user")
            | etc_file("/etc/dconf/db/local.d/00-theme")
        )

    def symlinks(self):
        h = self.host
        return (
            link(h, "gtk/gtk-3.0/settings.ini", ".config/gtk-3.0/settings.ini")
            | link(h, "gtk/gtk-4.0/settings.ini", ".config/gtk-4.0/settings.ini")
            | link(h, "gtk/gtkrc-2.0", ".gtkrc-2.0")
        )

    def on_enable(self, store):
        decman.sh("dconf update")

    def on_change(self, store):
        decman.sh("dconf update")

    @pacman.packages
    def pacman_packages(self):
        return {"adw-gtk-theme", "adwaita-icon-theme", "dconf"}


def module(host):
    return Gtk(host)
