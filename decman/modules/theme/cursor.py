from decman.plugins import pacman

from lib import SysModule, link


class Cursor(SysModule):
    """capitaine-cursors everywhere: niri (misc.kdl), GTK (gtk/*), X11 apps
    (Xresources), and as the fallback 'default' theme. XCURSOR_* env is in
    environment.d/10-session.conf."""


    def symlinks(self):
        h = self.host
        return (
            link(h, "cursor/index.theme", ".icons/default/index.theme")
            | link(h, "cursor/Xresources", ".Xresources")
        )

    @pacman.packages
    def pacman_packages(self):
        return {"capitaine-cursors"}


def module(host):
    return Cursor(host)
