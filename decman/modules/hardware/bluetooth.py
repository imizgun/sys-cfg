from decman.plugins import pacman, systemd

from lib import SysModule, etc_file


class Bluetooth(SysModule):
    """BlueZ; the why of each main.conf setting is commented in the file."""

    NAME = "hardware.bluetooth"

    def files(self):
        return etc_file("/etc/bluetooth/main.conf")

    @pacman.packages
    def pacman_packages(self):
        return {"bluez", "bluez-utils"}

    @systemd.units
    def units(self):
        return {"bluetooth.service"}


def module(host):
    return Bluetooth(host)
