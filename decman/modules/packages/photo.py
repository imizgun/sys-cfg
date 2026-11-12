from lib.packages import PackageSet


class Photo(PackageSet):
    PACMAN = {"rawtherapee", "darktable"}


def module(host):
    return Photo(host)
