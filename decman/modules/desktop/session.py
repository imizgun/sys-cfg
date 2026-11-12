from lib import SysModule, link


class Session(SysModule):
    """Session-wide env for the user's systemd/dbus-activated apps
    (was home.sessionVariables), see the comments in the file."""

    NAME = "desktop.session"

    def symlinks(self):
        return link(self.host, "environment.d/10-session.conf", ".config/environment.d/10-session.conf")


def module(host):
    return Session(host)
