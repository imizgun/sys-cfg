from decman import File
from decman.plugins import pacman, systemd

from lib import SysModule


class Networking(SysModule):

    def files(self):
        return {"/etc/hostname": File(content=f"{self.host.hostname}\n")}

    @pacman.packages
    def pacman_packages(self):
        return {"networkmanager"}

    @systemd.units
    def units(self):
        return {"NetworkManager.service"}


def module(host):
    return Networking(host)
