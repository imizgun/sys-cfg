from decman.plugins import pacman, systemd

from lib import SysModule


class Power(SysModule):
    """upower (battery info for noctalia; D-Bus activated) and
    power-profiles-daemon (noctalia's power profile switch)."""

    @pacman.packages
    def pacman_packages(self):
        return {"upower", "power-profiles-daemon"}

    @systemd.units
    def units(self):
        return {"power-profiles-daemon.service"}


def module(host):
    return Power(host)
