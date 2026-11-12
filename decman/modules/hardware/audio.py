from decman.plugins import pacman

from lib import SysModule


class Audio(SysModule):
    """PipeWire + rtkit. The user units (pipewire, wireplumber, pipewire-pulse)
    are socket-activated and enabled globally by the packages' presets."""

    NAME = "hardware.audio"

    @pacman.packages
    def pacman_packages(self):
        return {"pipewire", "pipewire-alsa", "pipewire-pulse", "wireplumber",
                "lib32-pipewire", "rtkit", "pavucontrol"}


def module(host):
    return Audio(host)
