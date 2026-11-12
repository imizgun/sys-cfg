from decman.plugins import pacman

from lib import SysModule


class Direnv(SysModule):
    """direnv; the fish hook is in dotfiles/fish/arch/integrations.fish.
    nix-direnv is dropped with Nix."""

    NAME = "programs.direnv"

    @pacman.packages
    def pacman_packages(self):
        return {"direnv"}


def module(host):
    return Direnv(host)
