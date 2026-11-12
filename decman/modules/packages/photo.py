from lib.packages import PackageSet


def module(host):
    return PackageSet(host, "packages.photo", pacman={"rawtherapee", "darktable"})
