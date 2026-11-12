from decman.plugins import aur, pacman

from lib import SysModule, etc_file


class Base(SysModule):
    """The packages every Arch install needs.

    decman removes explicitly installed packages that no module declares,
    so base/kernel/firmware must be listed here too.
    """

    NAME = "core.base"

    def files(self):
        return etc_file("/etc/sudoers.d/10-wheel", permissions=0o440)

    @pacman.packages
    def pacman_packages(self):
        return {
            "base",
            "base-devel",
            "linux",
            "linux-firmware",
            "amd-ucode",  # both hosts are AMD
            "btrfs-progs",
            "sudo",
            "man-db",
            # was modules/system/packages.nix
            "vim",
            "wget",
            "git",
        }

    @aur.packages
    def aur_packages(self):
        return {"decman"}


def module(host):
    return Base(host)
