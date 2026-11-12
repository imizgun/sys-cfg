from decman.extras.users import User, UserManager

from modules.core.aur import BUILD_USER


def module(host, mods):
    """The main user (+ groups requested by other modules) and the AUR build user.

    Passwords are not managed — set them with passwd once.
    """
    groups = {"wheel", "uucp"}  # uucp = serial ports (NixOS: dialout), for espflash
    for m in mods:
        groups |= m.groups()

    um = UserManager()
    um.add_user(User(
        username=host.username,
        uid=1000,
        group="users",
        home=host.home,
        shell="/usr/bin/fish",
        groups=tuple(sorted(groups)),
    ))
    um.add_user(User(
        username=BUILD_USER,
        home=f"/var/lib/{BUILD_USER}",
        shell="/usr/bin/nologin",
        system=True,
    ))
    return um
