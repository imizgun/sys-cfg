from decman.plugins import pacman

from lib import SysModule, link_tree


class Helix(SysModule):
    NAME = "programs.helix"

    def symlinks(self):
        return link_tree(self.host, "helix", ".config/helix")

    @pacman.packages
    def pacman_packages(self):
        return {"helix"}


def module(host):
    return Helix(host)
