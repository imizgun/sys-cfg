from decman.plugins import pacman

from lib import SysModule, link_tree


class Kitty(SysModule):
    NAME = "programs.kitty"

    def symlinks(self):
        return link_tree(self.host, "kitty", ".config/kitty")

    @pacman.packages
    def pacman_packages(self):
        return {"kitty"}


def module(host):
    return Kitty(host)
