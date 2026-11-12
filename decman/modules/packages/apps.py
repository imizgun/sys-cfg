from lib.packages import PackageSet


class Apps(PackageSet):
    PACMAN = {
        "telegram-desktop",
        "discord",
        "loupe",
        "obs-studio",
        "mpv",
        "easyeffects",
        "obsidian",
    }
    AUR = {
        "sonora-bin",
        "photocraft",
        "wordcraft",
        "onlyoffice-bin",
    }


def module(host):
    return Apps(host)
