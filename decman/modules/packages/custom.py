from decman.plugins import aur

from lib import PKGBUILDS, SysModule


class Custom(SysModule):
    """Packages built from PKGBUILDs in pkgbuilds/ (no AUR package exists)."""

    PKGS = ("ricture-git", "wayzoomy-git")

    @aur.custom_packages
    def custom_packages(self):
        return {aur.CustomPackage(name, pkgbuild_directory=str(PKGBUILDS / name))
                for name in self.PKGS}


def module(host):
    return Custom(host)
