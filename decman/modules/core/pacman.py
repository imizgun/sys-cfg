from decman.plugins import pacman, systemd

from lib import SysModule, etc_file


class Pacman(SysModule):
    """pacman.conf (multilib on, for Steam/lib32) and cache cleanup.

    Replaces nix.gc: paccache.timer keeps the last 3 versions weekly.
    """

    NAME = "core.pacman"

    def files(self):
        return etc_file("/etc/pacman.conf")

    @pacman.packages
    def pacman_packages(self):
        return {"pacman-contrib"}

    @systemd.units
    def units(self):
        return {"paccache.timer"}


def module(host):
    return Pacman(host)
