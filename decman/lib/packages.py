"""PackageSet: a module that only installs packages (no files/hooks)."""

from __future__ import annotations

from decman.plugins import aur, pacman

from lib import Host, SysModule


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

    @pacman.packages
    def pacman_packages(self) -> set[str]:
        return self._pacman

    @aur.packages
    def aur_packages(self) -> set[str]:
        return self._aur
