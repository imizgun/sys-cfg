"""Shared helpers for the decman source.

Paths are resolved from this file, not from the cwd: decman exec()s source.py
(so it has no __file__) after chdir'ing into decman/.
"""

from __future__ import annotations

import os
from dataclasses import dataclass, field
from pathlib import Path

import decman
from decman import File, Symlink

REPO = Path(__file__).resolve().parents[2]
DOTFILES = REPO / "dotfiles"
ETC = REPO / "etc"
PKGBUILDS = REPO / "pkgbuilds"


@dataclass(frozen=True)
class Mount:
    """A data disk mounted via a systemd .mount unit (fstab stays install-generated)."""

    what: str
    where: str
    fstype: str
    options: str = "defaults,nofail"


# CachyOS optimized repos per CPU level, as cachyos-repo.sh writes them
# (mirror.cachyos.org/cachyos-repo.tar.xz, install-*-repo.awk). They go above
# [core] in pacman.conf, followed by the generic [cachyos] repo.
CACHYOS_MARCH = {
    # march: (repo suffix, mirrorlist package, mirror dir)
    "znver4": ("znver4", "cachyos-v4-mirrorlist", "x86_64_v4"),  # Zen 4 / Zen 5
    "v4": ("v4", "cachyos-v4-mirrorlist", "x86_64_v4"),
    "v3": ("v3", "cachyos-v3-mirrorlist", "x86_64_v3"),
}


def cachyos_repos(march: str) -> list[tuple[str, str]]:
    """[(repo, mirrorlist path)] in pacman.conf order."""
    suffix, mirrorlist, _dir = CACHYOS_MARCH[march]
    ml = f"/etc/pacman.d/{mirrorlist}"
    return [
        (f"cachyos-{suffix}", ml),
        (f"cachyos-core-{suffix}", ml),
        (f"cachyos-extra-{suffix}", ml),
        ("cachyos", "/etc/pacman.d/cachyos-mirrorlist"),
    ]


@dataclass(frozen=True)
class Host:
    hostname: str
    username: str
    description: str = ""
    # "arch" or "cachyos" (+ march, a CACHYOS_MARCH key)
    distro: str = "arch"
    march: str = ""
    # "systemd-boot" or "limine" (limine: snapshot boot entries via
    # limine-snapper-sync — CachyOS' default)
    bootloader: str = "systemd-boot"
    mounts: tuple[Mount, ...] = ()
    # Host-only modules (packages for this machine, etc.) are appended to the
    # common list in modules/__init__.py.
    extra_modules: tuple = field(default_factory=tuple)

    def __post_init__(self):
        if self.distro not in ("arch", "cachyos"):
            raise ValueError(f"{self.hostname}: unknown distro {self.distro!r}")
        if self.distro == "cachyos" and self.march not in CACHYOS_MARCH:
            raise ValueError(f"{self.hostname}: cachyos needs march in {sorted(CACHYOS_MARCH)}")
        if self.bootloader not in ("systemd-boot", "limine"):
            raise ValueError(f"{self.hostname}: unknown bootloader {self.bootloader!r}")

    @property
    def home(self) -> str:
        return f"/home/{self.username}"

    @property
    def cachyos(self) -> bool:
        return self.distro == "cachyos"


class SysModule(decman.Module):
    """Base for every module here: carries the Host; the decman module name is
    derived from where the class lives — modules/core/boot.py -> "core.boot",
    the same key modules/__init__.py lists it under. (decman keeps these names
    in its store, so moving a file renames the module: decman then sees the old
    one disabled and the new one enabled.)

    Override decman's hooks / plugin-decorated methods as usual. groups() lets a
    module request supplementary groups for the main user; core.users adds them
    after the package step, since groups like libvirt/gamemode come with packages.
    """

    def __init__(self, host: Host) -> None:
        mod = type(self).__module__
        if not mod.startswith("modules."):
            raise TypeError(f"{type(self).__name__}: SysModule subclasses live under modules/ (got {mod})")
        super().__init__(mod.removeprefix("modules."))
        self.host = host

    def groups(self) -> set[str]:
        return set()


# ---------------------------------------------------------------- dotfiles


def dot(rel: str) -> str:
    """Absolute path of a file/dir under dotfiles/, asserting it exists."""
    p = DOTFILES / rel
    if not p.exists():
        raise FileNotFoundError(f"dotfiles/{rel} does not exist")
    return str(p)


def etc(rel: str) -> str:
    """Absolute path of a file under etc/ (system files copied into /etc)."""
    p = ETC / rel
    if not p.exists():
        raise FileNotFoundError(f"etc/{rel} does not exist")
    return str(p)


def link(host: Host, src: str, dst: str) -> dict[str, Symlink]:
    """~/<dst> -> <repo>/dotfiles/<src>. Edits in the repo are live, no rerun."""
    return {f"{host.home}/{dst}": Symlink(dot(src), owner=host.username)}


def link_tree(host: Host, src: str, dst: str) -> dict[str, Symlink]:
    """Symlink every file of dotfiles/<src> into ~/<dst>, keeping the layout.

    Per-file (not one dir symlink) so files an app writes next to its config
    (fish_variables, caches, ...) land in ~ instead of in the repo.
    """
    root = Path(dot(src))
    out: dict[str, Symlink] = {}
    for dirpath, _dirs, files in os.walk(root):
        for name in files:
            f = Path(dirpath) / name
            rel = f.relative_to(root)
            out[f"{host.home}/{dst}/{rel}"] = Symlink(str(f), owner=host.username)
    return out


def user_file(host: Host, src: str, dst: str, **kw) -> dict[str, File]:
    """Copy dotfiles/<src> to ~/<dst> owned by the user (for units, .desktop
    files and the like, where a real file is safer than a symlink)."""
    return {f"{host.home}/{dst}": File(source_file=dot(src), owner=host.username, **kw)}


def etc_file(dst: str, src: str | None = None, **kw) -> dict[str, File]:
    """Copy etc/<src or dst-without-/etc/> to <dst> (root-owned)."""
    rel = src if src is not None else dst.removeprefix("/etc/")
    return {dst: File(source_file=etc(rel), **kw)}
