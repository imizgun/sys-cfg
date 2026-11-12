from decman.plugins import aur, pacman, systemd

from lib import SysModule, etc_file


class Base(SysModule):
    """The packages every Arch install needs.

    decman removes explicitly installed packages that no module declares,
    so base/kernel/firmware must be listed here too.
    """

    NAME = "core.base"

    @property
    def kernel(self) -> str:
        # linux-cachyos: BORE/EEVDF + LTO/AutoFDO, built per march in its repos
        return "linux-cachyos" if self.host.cachyos else "linux"

    def files(self):
        return etc_file("/etc/sudoers.d/10-wheel", permissions=0o440)

    @pacman.packages
    def pacman_packages(self):
        return {
            "base",
            "base-devel",
            self.kernel,
            "linux-firmware",
            "mkinitcpio",  # initramfs generator (CachyOS uses it too)
            "amd-ucode",  # both hosts are AMD
            "btrfs-progs",
            "sudo",
            "man-db",
            # was modules/system/packages.nix
            "vim",
            "wget",
            "git",
            # NixOS ships these by default; Arch's base doesn't
            "openssh",
            "less",
            "which",
            "rsync",
            "strace",
            "xdg-utils",
            "dosfstools",  # mkfs.vfat / fsck for the ESP
            "e2fsprogs",   # ext4 data disk
        }

    @systemd.units
    def units(self):
        # enabled by default on NixOS
        return {"systemd-timesyncd.service", "fstrim.timer", "systemd-oomd.service"}

    @aur.packages
    def aur_packages(self):
        return {"decman"}


def module(host):
    return Base(host)
