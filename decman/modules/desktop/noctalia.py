from decman.plugins import pacman

from lib import DOTFILES, SysModule, link


class Noctalia(SysModule):
    """noctalia v5 shell. Reads every *.toml in ~/.config/noctalia, then GUI
    overrides from ~/.local/state/noctalia/settings.toml. Started by niri
    (dotfiles/niri/cfg/autostart.kdl)."""


    def symlinks(self):
        out = link(self.host, "noctalia/config.toml", ".config/noctalia/config.toml")
        host_rel = f"noctalia/hosts/{self.host.hostname}.toml"
        if (DOTFILES / host_rel).exists():
            out |= link(self.host, host_rel, ".config/noctalia/host.toml")
        return out

    @pacman.packages
    def pacman_packages(self):
        return {"noctalia"}


def module(host):
    return Noctalia(host)
