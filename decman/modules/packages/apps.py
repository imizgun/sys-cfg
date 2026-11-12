from lib.packages import PackageSet


def module(host):
    return PackageSet(host, "packages.apps", pacman={
        "telegram-desktop",
        "discord",
        "loupe",
        "obs-studio",
        "mpv",
        "easyeffects",
        "obsidian",
    }, aur={
        "vicinae-bin",
        "sonora-bin",
        "photocraft",
        "wordcraft",
        "onlyoffice-bin",
    })
