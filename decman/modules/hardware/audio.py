from decman.plugins import pacman

from lib import SysModule


class Audio(SysModule):
    """PipeWire + rtkit. The user units (pipewire, wireplumber, pipewire-pulse)
    are socket-activated and enabled globally by the packages' presets."""


    @pacman.packages
    def pacman_packages(self):
        return {"pipewire", "pipewire-alsa", "pipewire-pulse", "wireplumber",
                "lib32-pipewire", "rtkit", "pavucontrol",
                # DSP firmware for laptop codecs (NixOS: enableRedistributableFirmware)
                "sof-firmware", "alsa-firmware", "alsa-utils"}


def module(host):
    return Audio(host)
