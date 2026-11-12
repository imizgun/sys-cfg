from decman.plugins import aur, pacman

from lib import SysModule


class Games(SysModule):
    """Gaming on the PC (Steam itself: desktop.steam).

    proton-cachyos-slr is CachyOS' Proton (on the Steam Linux Runtime, as in
    cachyos-gaming-meta) — pick it per game or as default in Steam's
    compatibility settings. gamemode: `gamemoderun %command%` in launch
    options; the gamemode group gets renice + polkit-free CPU/GPU tuning.
    mangohud: `mangohud %command%`. gamescope: per-game compositor.
    """


    def groups(self):
        return {"gamemode"}

    @pacman.packages
    def pacman_packages(self):
        pkgs = {"gamemode", "lib32-gamemode", "mangohud", "lib32-mangohud", "gamescope",
                "supertuxkart"}
        if self.host.cachyos:
            pkgs.add("proton-cachyos-slr")
        return pkgs

    @aur.packages
    def aur_packages(self):
        return {"deadlock-modmanager-bin"}


def module(host):
    return Games(host)
