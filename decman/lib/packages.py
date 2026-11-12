"""PackageSet: a module that only installs packages (no files/hooks)."""

from __future__ import annotations

from decman.plugins import aur, pacman

from lib import SysModule

# AUR packages that CachyOS ships prebuilt in its [cachyos] repo: on CachyOS
# hosts they're installed with pacman instead of being built from the AUR.
# `check.py --packages` flags new ones ("is in official repo cachyos").
CACHYOS_PREBUILT = {"zen-browser-bin", "claude-code", "onlyoffice-bin", "yay"}


class PackageSet(SysModule):
    """Subclass with PACMAN / AUR sets; the name comes from the file, as for
    any SysModule:

        class Browsers(PackageSet):
            PACMAN = {"firefox"}
            AUR = {"zen-browser-bin"}
    """

    PACMAN: set[str] = set()
    AUR: set[str] = set()

    def _prebuilt(self) -> set[str]:
        return self.AUR & CACHYOS_PREBUILT if self.host.cachyos else set()

    @pacman.packages
    def pacman_packages(self) -> set[str]:
        return set(self.PACMAN) | self._prebuilt()

    @aur.packages
    def aur_packages(self) -> set[str]:
        return set(self.AUR) - self._prebuilt()
