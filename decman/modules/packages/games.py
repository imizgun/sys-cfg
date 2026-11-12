from lib.packages import PackageSet


def module(host):
    return PackageSet(host, "packages.games",
                      pacman={"supertuxkart"},
                      aur={"deadlock-modmanager-bin"})
