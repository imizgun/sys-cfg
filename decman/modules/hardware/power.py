from decman.plugins import pacman

from lib import SysModule


class Power(SysModule):
    """upower (battery info for noctalia); D-Bus activated, no unit to enable."""

    NAME = "hardware.power"

    @pacman.packages
    def pacman_packages(self):
        return {"upower"}


def module(host):
    return Power(host)
