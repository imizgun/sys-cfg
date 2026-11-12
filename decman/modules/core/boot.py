import decman
from decman.plugins import systemd

from lib import SysModule


class Boot(SysModule):
    """systemd-boot. Loader entries (root UUID, cmdline) are host-specific and
    created at install time — not managed here."""

    NAME = "core.boot"

    def on_enable(self, store):
        decman.sh("bootctl is-installed >/dev/null 2>&1 || bootctl install")

    @systemd.units
    def units(self):
        # updates the installed systemd-boot binary after systemd upgrades
        return {"systemd-boot-update.service"}


def module(host):
    return Boot(host)
