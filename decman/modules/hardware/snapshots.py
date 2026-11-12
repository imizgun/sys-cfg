import decman
from decman import File
from decman.plugins import pacman, systemd

from lib import SysModule, etc_file


class Snapshots(SysModule):
    """snapper timeline snapshots of /home (btrfs) every 2 days."""

    NAME = "hardware.snapshots"

    def files(self):
        return {
            **etc_file("/etc/snapper/configs/home"),
            "/etc/conf.d/snapper": File(content='SNAPPER_CONFIGS="home"\n'),
            **etc_file("/etc/systemd/system/snapper-timeline.timer.d/override.conf"),
        }

    def file_variables(self):
        return {"%USER%": self.host.username}

    def on_enable(self, store):
        # snapper won't create the .snapshots subvolume itself (snapper-configs(5))
        decman.sh(
            "[ -d /home/.snapshots ] || "
            "{ btrfs subvolume create /home/.snapshots && chmod 750 /home/.snapshots; }"
        )

    @pacman.packages
    def pacman_packages(self):
        return {"snapper"}

    @systemd.units
    def units(self):
        return {"snapper-timeline.timer", "snapper-cleanup.timer"}


def module(host):
    return Snapshots(host)
