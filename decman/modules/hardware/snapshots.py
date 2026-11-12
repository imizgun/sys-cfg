import decman
from decman import File
from decman.plugins import pacman, systemd

from lib import SysModule, etc_file


class Snapshots(SysModule):
    """btrfs snapshots with snapper:
    - /home: timeline, every 2 days (as on NixOS)
    - /:     pre/post around every pacman transaction (snap-pac), last 10 kept

    Rollback of / is manual (systemd-boot can't boot snapshots) — see
    MIGRATION.md "Rolling back /".
    """

    # config name -> mountpoint whose .snapshots subvolume snapper needs
    CONFIGS = {"home": "/home", "root": "/"}


    def files(self):
        return {
            **etc_file("/etc/snapper/configs/home"),
            **etc_file("/etc/snapper/configs/root"),
            "/etc/conf.d/snapper": File(content=f'SNAPPER_CONFIGS="{" ".join(self.CONFIGS)}"\n'),
            **etc_file("/etc/systemd/system/snapper-timeline.timer.d/override.conf"),
        }

    def file_variables(self):
        return {"%USER%": self.host.username}

    def before_update(self, store):
        # snapper won't create the .snapshots subvolume itself (snapper-configs(5)).
        # Before the pacman step, so snap-pac's first snapshot has somewhere to go.
        # archinstall's default layout already mounts @.snapshots at /.snapshots.
        for mnt in self.CONFIGS.values():
            d = f"{mnt.rstrip('/')}/.snapshots"
            decman.sh(
                f"[ -d {d} ] || {{ btrfs subvolume create {d} && chmod 750 {d}; }}"
            )

    @pacman.packages
    def pacman_packages(self):
        return {"snapper", "snap-pac"}

    @systemd.units
    def units(self):
        return {"snapper-timeline.timer", "snapper-cleanup.timer"}


def module(host):
    return Snapshots(host)
