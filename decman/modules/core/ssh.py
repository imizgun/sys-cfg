from decman.plugins import pacman, systemd

from lib import SysModule, etc_file, user_file


class Ssh(SysModule):
    """sshd, key-only (as nix/modules/system/core/ssh.nix). Settings go to a
    drop-in, Arch's stock sshd_config includes sshd_config.d/*.conf. Port 22 is
    opened in etc/nftables.conf (core.firewall)."""

    def files(self):
        return {
            **etc_file("/etc/ssh/sshd_config.d/10-sys-cfg.conf", permissions=0o644),
            # sshd's StrictModes wants it user-owned and not group/world-writable
            **user_file(self.host, "ssh/authorized_keys", ".ssh/authorized_keys", permissions=0o600),
        }

    @pacman.packages
    def pacman_packages(self):
        return {"openssh"}

    @systemd.units
    def units(self):
        return {"sshd.service"}


def module(host):
    return Ssh(host)
