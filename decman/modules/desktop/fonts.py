from decman.plugins import pacman

from lib import SysModule, link_tree


class Fonts(SysModule):
    NAME = "desktop.fonts"

    def symlinks(self):
        return link_tree(self.host, "fontconfig", ".config/fontconfig")

    @pacman.packages
    def pacman_packages(self):
        return {
            "noto-fonts",
            "noto-fonts-cjk",
            "noto-fonts-emoji",
            "ttf-liberation",
            "ttf-jetbrains-mono",
            "ttf-firacode-nerd",
            "ttf-jetbrains-mono-nerd",
            "ttf-nerd-fonts-symbols",
        }


def module(host):
    return Fonts(host)
