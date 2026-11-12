from decman.plugins import aur, pacman

from lib import SysModule, user_file


class Steam(SysModule):
    """Steam (multilib) + Millennium. The .desktop override forces GDK_SCALE=1,
    see the comment in the file."""


    def files(self):
        return user_file(self.host, "applications/steam.desktop",
                         ".local/share/applications/steam.desktop")

    @pacman.packages
    def pacman_packages(self):
        return {"steam"}

    # @aur.packages
    # def aur_packages(self):
    #     return {"millennium"}


def module(host):
    return Steam(host)
