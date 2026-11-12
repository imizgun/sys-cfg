from decman.plugins import pacman

from lib import SysModule


class Gpu(SysModule):
    """AMD graphics (both hosts), incl. 32-bit drivers for Steam."""


    @pacman.packages
    def pacman_packages(self):
        return {"mesa", "vulkan-radeon", "lib32-mesa", "lib32-vulkan-radeon", "amdgpu_top"}


def module(host):
    return Gpu(host)
