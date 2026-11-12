from decman import File
from decman.plugins import pacman, systemd

from lib import SysModule


def unit_name(where: str) -> str:
    """systemd-escape --path --suffix=mount (enough for plain paths)."""
    return where.strip("/").replace("-", "\\x2d").replace("/", "-") + ".mount"


class Storage(SysModule):
    """Removable media in Nautilus (gvfs -> udisks2 -> polkit), plus the host's
    data disks as .mount units — fstab itself stays install-generated."""

    NAME = "hardware.storage"

    def files(self):
        out = {}
        for m in self.host.mounts:
            out[f"/etc/systemd/system/{unit_name(m.where)}"] = File(content=(
                "[Unit]\n"
                f"Description=Mount {m.where}\n\n"
                "[Mount]\n"
                f"What={m.what}\n"
                f"Where={m.where}\n"
                f"Type={m.fstype}\n"
                f"Options={m.options}\n\n"
                "[Install]\n"
                "WantedBy=multi-user.target\n"
            ))
        return out

    @pacman.packages
    def pacman_packages(self):
        return {"gvfs", "udisks2", "polkit"}

    @systemd.units
    def units(self):
        return {unit_name(m.where) for m in self.host.mounts}


def module(host):
    return Storage(host)
