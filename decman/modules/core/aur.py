import decman

from lib.packages import PackageSet

BUILD_USER = "builduser"


class Aur(PackageSet):
    """AUR builds run as a dedicated user with a real $HOME (cargo/npm-based
    PKGBUILDs need a writable home; the default `nobody` has none). The user
    itself is created in core.users.

    yay is kept for ad-hoc AUR search/inspection (prebuilt in [cachyos]);
    anything installed with it that no module declares is removed on the next
    decman run.
    """

    AUR = {"yay"}


def module(host):
    decman.aur.makepkg_user = BUILD_USER
    return Aur(host)
