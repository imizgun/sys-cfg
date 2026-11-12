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


@dataclass(frozen=True)
class Host:
    hostname: str
    username: str
    description: str = ""
    mounts: tuple[Mount, ...] = ()
    # Host-only modules (packages for this machine, etc.) are appended to the
    # common list in modules/__init__.py.
    extra_modules: tuple = field(default_factory=tuple)

    @property
    def home(self) -> str:
        return f"/home/{self.username}"


class SysModule(decman.Module):
    """Base for every module here: carries the Host and a unique name.

    Subclasses set NAME (e.g. "core.boot") and override decman's hooks /
    plugin-decorated methods as usual. groups() lets a module request
    supplementary groups for the main user; core.users collects them, since
    decman's UserManager must know the full set when it creates the user.
    """

    NAME: str = ""

    def __init__(self, host: Host) -> None:
        if not self.NAME:
            raise TypeError(f"{type(self).__name__} must set NAME")
        super().__init__(self.NAME)
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
