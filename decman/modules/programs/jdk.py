from decman.plugins import pacman

from lib import SysModule


class Jdk(SysModule):
    """JDK 25 (as on NixOS) + Maven. With a single JDK installed,
    archlinux-java picks it as default automatically."""


    @pacman.packages
    def pacman_packages(self):
        return {"jdk25-openjdk", "maven"}


def module(host):
    return Jdk(host)
