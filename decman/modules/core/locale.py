import decman
from decman import File

from lib import SysModule

LC = "pl_PL.UTF-8"
LC_VARS = ["ADDRESS", "IDENTIFICATION", "MEASUREMENT", "MONETARY", "NAME",
           "NUMERIC", "PAPER", "TELEPHONE", "TIME"]


class Locale(SysModule):
    """Timezone, locales (en_US UI + pl_PL formats), console keymap.

    The graphical keyboard layout lives in dotfiles/niri (input.kdl).
    """


    def files(self):
        conf = "LANG=en_US.UTF-8\n" + "".join(f"LC_{v}={LC}\n" for v in LC_VARS)
        return {
            "/etc/locale.gen": File(content="en_US.UTF-8 UTF-8\npl_PL.UTF-8 UTF-8\n"),
            "/etc/locale.conf": File(content=conf),
            "/etc/vconsole.conf": File(content="KEYMAP=pl2\n"),
        }

    def symlinks(self):
        return {"/etc/localtime": "/usr/share/zoneinfo/Europe/Warsaw"}

    def on_enable(self, store):
        decman.sh("locale-gen")

    def on_change(self, store):
        decman.sh("locale-gen")


def module(host):
    return Locale(host)
