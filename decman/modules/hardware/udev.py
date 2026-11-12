from decman.plugins import aur, pacman

from lib import SysModule


class Udev(SysModule):
    """Keyboard flashing/config: qmk ships its udev rules; VIA for VIA keyboards."""

    NAME = "hardware.udev"

    @pacman.packages
    def pacman_packages(self):
        return {"qmk"}

    @aur.packages
    def aur_packages(self):
        return {"via-bin"}


def module(host):
    return Udev(host)
