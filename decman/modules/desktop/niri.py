from decman.plugins import pacman, systemd

from lib import SysModule, etc_file, link_tree


class Niri(SysModule):
    """niri + greetd/tuigreet login, portals, keyring, Xwayland bridge."""

    NAME = "desktop.niri"

    def files(self):
        return etc_file("/etc/greetd/config.toml")

    def symlinks(self):
        return link_tree(self.host, "niri", ".config/niri")

    @pacman.packages
    def pacman_packages(self):
        return {
            "niri",
            "greetd",
            "greetd-tuigreet",
            # what NixOS' programs.niri pulled in implicitly
            "xdg-desktop-portal-gnome",
            "xdg-desktop-portal-gtk",
            "gnome-keyring",
            "gcr-4",  # gcr-ssh-agent (SSH_AUTH_SOCK in environment.d/10-session.conf)
            "polkit",
            # X11 apps
            "xorg-xwayland",
            "xwayland-satellite",
        }

    @systemd.units
    def units(self):
        return {"greetd.service"}

    @systemd.user_units
    def user_units(self):
        # ssh-agent from gcr, as on NixOS (programs.ssh via gnome-keyring)
        return {self.host.username: {"gcr-ssh-agent.socket"}}


def module(host):
    return Niri(host)
