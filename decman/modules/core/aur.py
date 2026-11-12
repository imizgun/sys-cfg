import decman

from lib.packages import PackageSet

BUILD_USER = "builduser"
# decman's default is /tmp/decman/build, but /tmp is tmpfs (half the RAM) and
# the clean chroot + toolchains + JetBrains IDEs don't fit there. /var/cache
# is its own btrfs subvolume on CachyOS (@cache), so builds stay out of the
# root snapshots. decman wipes this dir at the start of every AUR build.
BUILD_DIR = "/var/cache/decman/build"


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
    decman.aur.build_dir = BUILD_DIR
    return Aur(host)
