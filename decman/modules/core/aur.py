import decman

from lib import etc_file
from lib.packages import PackageSet

BUILD_USER = "builduser"
# decman's default is /tmp/decman/build, but /tmp is tmpfs (half the RAM) and
# the clean chroot + toolchains + JetBrains IDEs don't fit there. /var/cache
# is its own btrfs subvolume on CachyOS (@cache), so builds stay out of the
# root snapshots. decman wipes this dir at the start of every AUR build.
BUILD_DIR = "/var/cache/decman/build"
# pacman.conf for the build chroot (see the file); the files step that writes
# it runs before the aur step.
CHROOT_PACMAN_CONF = "/etc/decman/pacman-chroot.conf"


def chroot_commands(base):
    """decman's AurCommands with `-C CHROOT_PACMAN_CONF` for mkarchroot and
    every arch-nspawn call (decman exposes them for overriding as
    decman.aur.commands). makechrootpkg copies the chroot, config included."""

    def nspawn(cmd):
        # arch-nspawn [options] working-dir ...
        return [cmd[0], "-C", CHROOT_PACMAN_CONF, *cmd[1:]]

    class ChrootCommands(type(base)):
        def make_chroot(self, chroot_dir, with_pkgs):
            return ["mkarchroot", "-C", CHROOT_PACMAN_CONF, chroot_dir, *with_pkgs]

        def install_chroot(self, chroot_dir, packages):
            return nspawn(super().install_chroot(chroot_dir, packages))

        def resolve_real_name_chroot(self, chroot_dir, pkg):
            return nspawn(super().resolve_real_name_chroot(chroot_dir, pkg))

        def remove_chroot(self, chroot_dir, packages):
            return nspawn(super().remove_chroot(chroot_dir, packages))

    return ChrootCommands()


class Aur(PackageSet):
    """AUR builds run as a dedicated user with a real $HOME (cargo/npm-based
    PKGBUILDs need a writable home; the default `nobody` has none). The user
    itself is created in core.users.

    yay is kept for ad-hoc AUR search/inspection (prebuilt in [cachyos]);
    anything installed with it that no module declares is removed on the next
    decman run.
    """

    AUR = {"yay"}

    def files(self):
        return etc_file(CHROOT_PACMAN_CONF, permissions=0o644)


def module(host):
    decman.aur.makepkg_user = BUILD_USER
    decman.aur.build_dir = BUILD_DIR
    decman.aur.commands = chroot_commands(decman.aur.commands)
    return Aur(host)
