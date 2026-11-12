from decman.plugins import pacman, systemd

from lib import SysModule, cachyos_repos, etc_file


class Pacman(SysModule):
    """pacman.conf (multilib on, for Steam/lib32) and cache cleanup.

    On CachyOS hosts the optimized repos for host.march go above [core],
    exactly as CachyOS' installer writes them. Replaces nix.gc:
    paccache.timer keeps the last 3 versions weekly.
    """


    def files(self):
        return etc_file("/etc/pacman.conf")

    def file_variables(self):
        repos = ""
        if self.host.cachyos:
            repos = "# CachyOS repos (decman/modules/core/pacman.py)\n" + "".join(
                f"[{name}]\nInclude = {ml}\n\n" for name, ml in cachyos_repos(self.host.march)
            )
        return {"%CACHYOS_REPOS%": repos}

    @pacman.packages
    def pacman_packages(self):
        return {"pacman-contrib"}

    @systemd.units
    def units(self):
        return {"paccache.timer"}


def module(host):
    return Pacman(host)
