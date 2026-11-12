from lib.packages import PackageSet


class Browsers(PackageSet):
    PACMAN = {"firefox"}
    AUR = {"zen-browser-bin", "google-chrome"}


def module(host):
    return Browsers(host)
