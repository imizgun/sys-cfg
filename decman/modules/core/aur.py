import decman

from lib import SysModule

BUILD_USER = "builduser"


class Aur(SysModule):
    """AUR builds run as a dedicated user with a real $HOME (cargo/npm-based
    PKGBUILDs need a writable home; the default `nobody` has none). The user
    itself is created in core.users."""



def module(host):
    decman.aur.makepkg_user = BUILD_USER
    return Aur(host)
