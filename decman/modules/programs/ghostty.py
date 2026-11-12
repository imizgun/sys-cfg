from decman.plugins import pacman, systemd

from lib import SysModule, link

UNIT = "app-com.mitchellh.ghostty.service"


class Ghostty(SysModule):
    """Ghostty with one long-lived GTK instance (D-Bus activatable unit shipped
    by the package), started with the session so Mod+T is instant."""

    NAME = "programs.ghostty"

    def symlinks(self):
        return link(self.host, "ghostty/config.ghostty", ".config/ghostty/config.ghostty")

    @pacman.packages
    def pacman_packages(self):
        return {"ghostty"}

    @systemd.user_units
    def user_units(self):
        return {self.host.username: {UNIT}}


def module(host):
    return Ghostty(host)
