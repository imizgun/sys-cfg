"""PackageSet: a module that only installs packages (no files/hooks)."""

from __future__ import annotations

from decman.plugins import aur, pacman

from lib import Host, SysModule

# AUR packages that CachyOS ships prebuilt in its [cachyos] repo: on CachyOS
# hosts they're installed with pacman instead of being built from the AUR.
# `check.py --packages` flags new ones ("is in official repo cachyos").
CACHYOS_PREBUILT = {"zen-browser-bin", "claude-code", "onlyoffice-bin"}


class PackageSet(SysModule):
    """Declare a named group of packages without writing a class for it.

        PackageSet(host, "packages.browsers",
                   pacman={"firefox"}, aur={"zen-browser-bin"})
    """

    def __init__(self, host: Host, name: str, *, pacman: set[str] = frozenset(),
                 aur: set[str] = frozenset()) -> None:
        self.NAME = name
        super().__init__(host)
        self._pacman = set(pacman)
        self._aur = set(aur)

    def _prebuilt(self) -> set[str]:
        return self._aur & CACHYOS_PREBUILT if self.host.cachyos else set()

    @pacman.packages
    def pacman_packages(self) -> set[str]:
        return self._pacman | self._prebuilt()

    @aur.packages
    def aur_packages(self) -> set[str]:
        return self._aur - self._prebuilt()
