import decman
from decman.plugins import pacman, systemd

from lib import CACHYOS_MARCH, SysModule

# CachyOS repo signing key (cachyos-repo.sh)
KEY = "F3B607488DB35A47"


class CachyOS(SysModule):
    """What makes it CachyOS besides the repos (core.pacman) and the kernel
    (core.base): keyring + mirrorlists, the distro's tuning (cachyos-settings:
    zram, ananicy-cpp rules, sysctl, ntsync), its pacman hooks, mirror ranking,
    hardware detection.

    Left out on purpose: cachyos-hello, cachyos-kernel-manager, paru (decman
    does AUR), the cachyos-niri-noctalia preset (dotfiles/ has our own),
    cachyos-fish-config (dotfiles/fish).
    """


    def before_update(self, store):
        # Normally done by the installer; makes a plain Arch -> CachyOS switch
        # work too. Before the pacman step, which syncs the CachyOS repos.
        decman.sh(
            f"pacman-key --list-keys {KEY} >/dev/null 2>&1 || "
            f"{{ pacman-key --recv-keys {KEY} --keyserver keyserver.ubuntu.com && "
            f"pacman-key --lsign-key {KEY}; }}"
        )

    @pacman.packages
    def pacman_packages(self):
        _suffix, mirrorlist, _dir = CACHYOS_MARCH[self.host.march]
        return {
            "cachyos-keyring",
            "cachyos-mirrorlist",
            mirrorlist,
            "cachyos-settings",
            "cachyos-hooks",
            "cachyos-rate-mirrors",
            "chwd",
        }

    @systemd.units
    def units(self):
        return {"cachyos-rate-mirrors.timer"}


def module(host):
    return CachyOS(host)
