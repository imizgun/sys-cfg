from decman.extras.users import User, UserManager

from modules.core.aur import BUILD_USER


def module(host, mods):
    """Groups for the main user + the AUR build user.

    The main user comes from the installer and is not add_user()'d: decman's
    UserManager applies add_user() groups *before* the package step, when
    package-created groups (libvirt, gamemode, ...) don't exist yet on a fresh
    system. add_user_to_group() runs after it. Login shell: programs.fish.
    Passwords are not managed — set them with passwd once.
    """
    groups = {"wheel", "uucp"}  # uucp = serial ports (NixOS: dialout), for espflash
    for m in mods:
        groups |= m.groups()

    um = UserManager()
    for g in sorted(groups):
        um.add_user_to_group(host.username, g)
    um.add_user(User(
        username=BUILD_USER,
        home=f"/var/lib/{BUILD_USER}",
        shell="/usr/bin/nologin",
        system=True,
    ))
    return um
