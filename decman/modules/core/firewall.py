from decman.plugins import pacman, systemd

from lib import SysModule, etc_file


class Firewall(SysModule):
    """Inbound default-deny, like NixOS' default networking.firewall.
    Only the `inet filter` table is managed, so libvirt's own NAT tables
    survive reloads (no `flush ruleset`)."""


    def files(self):
        return etc_file("/etc/nftables.conf", permissions=0o755)

    @pacman.packages
    def pacman_packages(self):
        return {"nftables"}

    @systemd.units
    def units(self):
        return {"nftables.service"}


def module(host):
    return Firewall(host)
