from lib.packages import PackageSet


def module(host):
    return PackageSet(host, "packages.browsers",
                      pacman={"firefox"},
                      aur={"zen-browser-bin", "google-chrome"})
