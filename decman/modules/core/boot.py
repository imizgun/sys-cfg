import decman
from decman.plugins import pacman, systemd

from lib import SysModule


class Boot(SysModule):
    """Bootloader per host.bootloader. Kernel cmdline (root UUID etc.) is
    host-specific and set at install time — not managed here.

    - systemd-boot: loader entries from the installer; rollback of / from the ISO.
    - limine (CachyOS default): limine-mkinitcpio-hook writes kernel entries on
      every kernel/initramfs update; limine-snapper-sync turns snapper's /
      snapshots (snap-pac, hardware.snapshots) into boot entries and copies
      their kernels to the ESP, so a snapshot boots with matching modules.
      It expects snapshots at /@/.snapshots (what hardware.snapshots creates).
    """

    NAME = "core.boot"

    def on_enable(self, store):
        if self.host.bootloader == "systemd-boot":
            decman.sh("bootctl is-installed >/dev/null 2>&1 || bootctl install")

    @pacman.packages
    def pacman_packages(self):
        if self.host.bootloader == "limine":
            return {"limine", "limine-mkinitcpio-hook", "limine-snapper-sync"}
        return set()

    @systemd.units
    def units(self):
        if self.host.bootloader == "limine":
            return {"limine-snapper-sync.service"}
        # updates the installed systemd-boot binary after systemd upgrades
        return {"systemd-boot-update.service"}


def module(host):
    return Boot(host)
