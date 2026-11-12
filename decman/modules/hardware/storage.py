from decman import File
from decman.plugins import pacman, systemd

from lib import SysModule


def unit_name(where: str, suffix: str) -> str:
    """systemd-escape --path --suffix=<suffix> (enough for plain paths)."""
    return where.strip("/").replace("-", "\\x2d").replace("/", "-") + "." + suffix


class Storage(SysModule):
    """Removable media in Nautilus (gvfs -> udisks2 -> polkit), plus the host's
    data disks — fstab itself stays install-generated.

    Data disks are .automount + .mount (mounted on first access): like fstab's
    `nofail` on NixOS, a missing disk never holds up boot. A plain enabled
    .mount would make multi-user.target wait 90s for the device.
    """

    NAME = "hardware.storage"

    def files(self):
        out = {}
        for m in self.host.mounts:
            base = f"/etc/systemd/system/{unit_name(m.where, '')}"
            out[base + "mount"] = File(content=(
                "[Unit]\n"
                f"Description=Mount {m.where}\n\n"
                "[Mount]\n"
                f"What={m.what}\n"
                f"Where={m.where}\n"
                f"Type={m.fstype}\n"
                f"Options={m.options}\n"
            ))
            out[base + "automount"] = File(content=(
                "[Unit]\n"
                f"Description=Automount {m.where}\n\n"
                "[Automount]\n"
                f"Where={m.where}\n\n"
                "[Install]\n"
                "WantedBy=local-fs.target\n"
            ))
        return out

    @pacman.packages
    def pacman_packages(self):
        return {"gvfs", "udisks2", "polkit"}

    @systemd.units
    def units(self):
        return {unit_name(m.where, "automount") for m in self.host.mounts}


def module(host):
    return Storage(host)
