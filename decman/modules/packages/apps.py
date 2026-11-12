from lib.packages import PackageSet


class Apps(PackageSet):
    PACMAN = {
        "telegram-desktop",
        "webkit2gtk-4.1",  # optdep of telegram: bot mini apps / in-app web pages
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
