"""Module registry. Order matters only for hook execution order.

Every modules/<group>/<name>.py exposes `module(host) -> SysModule`.
Host-only modules are listed in hosts/<host>.py (extra_modules).
"""

from importlib import import_module

COMMON = [
    # core: boots, networks, and identifies the machine
    "core.pacman",
    "core.base",
    "core.aur",
    "core.boot",
    "core.locale",
    "core.networking",
    # hardware: device-level enablement
    "hardware.gpu",
    "hardware.audio",
    "hardware.bluetooth",
    "hardware.power",
    "hardware.storage",
    "hardware.snapshots",
    "hardware.udev",
    "hardware.virt",
    # desktop: the graphical session
    "desktop.session",
    "desktop.niri",
    "desktop.noctalia",
    "desktop.steam",
    "desktop.fonts",
    # programs: configured tools
    "programs.fish",
    "programs.ghostty",
    "programs.nautilus",
    "programs.helix",
    "programs.direnv",
    "programs.jdk",
    "programs.kitty",
    # theme: appearance, shared across GTK/niri/cursor
    "theme.gtk",
    "theme.cursor",
    # packages: plain package lists
    "packages.browsers",
    "packages.dev",
    "packages.apps",
    "packages.custom",
]


def build(host) -> list:
    mods = [import_module(f"modules.{n}").module(host) for n in COMMON + list(host.extra_modules)]
    # Users last: it collects groups() from every other module.
    mods.append(import_module("modules.core.users").module(host, mods))
    return mods
