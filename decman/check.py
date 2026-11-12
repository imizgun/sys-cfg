#!/usr/bin/env python3
"""Offline sanity check of the decman source — no root, no Arch, no decman.

    python3 decman/check.py                # all hosts
    python3 decman/check.py mainpc -v       # one host, list everything
    python3 decman/check.py --packages     # + verify names in Arch(/CachyOS) repos / AUR
    python3 decman/check.py mainpc --show /etc/pacman.conf   # rendered file

decman itself is replaced by a minimal stub of its public API (File, Symlink,
Module, plugin decorators, UserManager), so this checks *our* code: imports,
module names, that every source file / symlink target exists, that no two
modules claim the same path, and (optionally) that every package exists.
It does not run hooks and does not prove decman will accept the config —
for that, run `sudo decman --source decman/source.py` on Arch (a VM is fine).
"""

from __future__ import annotations

import json
import os
import re
import sys
import tarfile
import time
import types
import urllib.parse
import urllib.request
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parent
CACHE = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "sys-cfg" / "archdb"
MIRROR = "https://geo.mirror.pkgbuild.com"
CACHYOS_MIRROR = "https://mirror.cachyos.org/repo"
UA = {"User-Agent": "sys-cfg-check/1.0"}  # mirror.cachyos.org rejects Python's default UA


def fetch(url: str, dest: Path | None = None, timeout: int = 60) -> bytes:
    with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=timeout) as r:
        data = r.read()
    if dest is not None:
        dest.write_bytes(data)
    return data


# ------------------------------------------------------------------ stub


def install_stub() -> None:
    def mod(name: str) -> types.ModuleType:
        m = types.ModuleType(name)
        sys.modules[name] = m
        return m

    d = mod("decman")

    class File:
        def __init__(self, source_file=None, content=None, bin_file=False, encoding="utf-8",
                     owner=None, group=None, permissions=0o644):
            if (source_file is None) == (content is None):
                raise ValueError("File: exactly one of source_file / content")
            self.source_file, self.content = source_file, content
            self.owner, self.group, self.permissions = owner, group, permissions

    class Directory:
        def __init__(self, source_directory, bin_files=False, encoding="utf-8",
                     owner=None, group=None, permissions=0o644):
            self.source_directory, self.owner = source_directory, owner

    class Symlink:
        def __init__(self, target, owner=None, group=None):
            self.target, self.owner, self.group = target, owner, group

    class Module:
        def __init__(self, name: str) -> None:
            self.name = name

        def before_update(self, store): ...
        def after_update(self, store): ...
        def on_enable(self, store): ...
        def on_change(self, store): ...
        def files(self): return {}
        def directories(self): return {}
        def symlinks(self): return {}
        def file_variables(self): return {}

    class Store(dict):
        def ensure(self, key, default):
            self.setdefault(key, default)

    def _no_run(*_a, **_k):
        raise RuntimeError("command executed at import time (only hooks may run commands)")

    class _Pkgs:
        def __init__(self):
            self.packages: set[str] = set()
            self.ignored_packages: set[str] = set()

    class _Aur(_Pkgs):
        def __init__(self):
            super().__init__()
            self.custom_packages: set = set()
            self.makepkg_user = "nobody"

    class _Systemd:
        def __init__(self):
            self.enabled_units: set[str] = set()
            self.enabled_user_units: dict[str, set[str]] = {}

    d.File, d.Directory, d.Symlink, d.Module, d.Store = File, Directory, Symlink, Module, Store
    d.sh = d.prg = _no_run
    d.files, d.directories, d.symlinks, d.modules = {}, {}, {}, []
    d.execution_order = ["files", "pacman", "aur", "systemd"]
    d.pacman, d.aur, d.systemd = _Pkgs(), _Aur(), _Systemd()

    cfg = mod("decman.config")
    d.config = cfg

    def marker(kind):
        def deco(fn):
            fn._check_kind = kind
            return fn
        return deco

    plugins = mod("decman.plugins")
    plugins.__path__ = []
    d.plugins = plugins
    pm = mod("decman.plugins.pacman")
    pm.packages = marker("pacman")
    au = mod("decman.plugins.aur")
    au.packages = marker("aur")
    au.custom_packages = marker("custom")

    class CustomPackage:
        def __init__(self, pkgname, git_url=None, pkgbuild_directory=None):
            if (git_url is None) == (pkgbuild_directory is None):
                raise ValueError("CustomPackage: exactly one of git_url / pkgbuild_directory")
            self.pkgname, self.git_url, self.pkgbuild_directory = pkgname, git_url, pkgbuild_directory

        def __hash__(self): return hash(self.pkgname)
        def __eq__(self, o): return isinstance(o, CustomPackage) and o.pkgname == self.pkgname

    au.CustomPackage = CustomPackage
    sd = mod("decman.plugins.systemd")
    sd.units = marker("units")
    sd.user_units = marker("user_units")
    plugins.pacman, plugins.aur, plugins.systemd = pm, au, sd

    extras = mod("decman.extras")
    extras.__path__ = []
    users = mod("decman.extras.users")
    from dataclasses import dataclass
    from typing import Optional

    @dataclass(frozen=True)
    class User:
        username: str
        uid: Optional[int] = None
        group: Optional[str] = None
        home: Optional[str] = None
        shell: Optional[str] = None
        groups: tuple = ()
        system: bool = False

    @dataclass(frozen=True)
    class Group:
        groupname: str
        gid: Optional[int] = None
        system: bool = False

    class UserManager(Module):
        def __init__(self):
            super().__init__("usermanager")
            self.users, self.groups_, self.extra_groups = [], [], {}

        def add_user(self, u): self.users.append(u)
        def add_group(self, g): self.groups_.append(g)
        def add_user_to_group(self, u, g): self.extra_groups.setdefault(u, set()).add(g)

    users.User, users.Group, users.UserManager = User, Group, UserManager


# ------------------------------------------------------------------ run


def load_host(hostname: str):
    for name in list(sys.modules):
        if name == "decman" or name.startswith(("decman.", "lib", "hosts", "modules")):
            del sys.modules[name]
    install_stub()
    import decman  # the stub

    os.environ["SYSCFG_HOST"] = hostname
    cwd = os.getcwd()
    os.chdir(HERE)
    sys.path.insert(0, str(HERE))
    try:
        exec(compile((HERE / "source.py").read_text(), "source.py", "exec"), {"__name__": "__decman_source__"})
    finally:
        os.chdir(cwd)
        sys.path.remove(str(HERE))
    decman.HOST = sys.modules["hosts"].load(hostname)
    return decman


def collect(decman) -> dict:
    out = {"pacman": set(decman.pacman.packages), "aur": set(decman.aur.packages),
           "custom": set(decman.aur.custom_packages), "units": set(decman.systemd.enabled_units),
           "user_units": {}, "paths": {}, "errors": [], "modules": [], "users": [],
           "extra_groups": {}, "host": decman.HOST, "vars": {}}

    def claim(path, kind, owner_mod, obj):
        if path in out["paths"]:
            out["errors"].append(f"{path}: claimed by {out['paths'][path][1]} and {owner_mod}")
        out["paths"][path] = (kind, owner_mod, obj)

    names = set()
    for m in decman.modules:
        if m.name in names:
            out["errors"].append(f"duplicate module name {m.name}")
        names.add(m.name)
        out["modules"].append(m.name)
        if hasattr(m, "users"):
            out["users"] += m.users
            for u, g in m.extra_groups.items():
                out["extra_groups"].setdefault(u, set()).update(g)
        for attr in dir(type(m)):
            fn = getattr(type(m), attr, None)
            kind = getattr(fn, "_check_kind", None)
            if not kind:
                continue
            val = getattr(m, attr)()
            if kind == "user_units":
                for u, s in val.items():
                    out["user_units"].setdefault(u, set()).update(s)
            else:
                out[kind] |= set(val)
        for p, f in m.files().items():
            claim(p, "file", m.name, f)
            out["vars"][p] = m.file_variables()
        for p, dd in m.directories().items():
            claim(p, "dir", m.name, dd)
        for p, s in m.symlinks().items():
            claim(p, "link", m.name, s)
    return out


def render(res: dict, path: str) -> str:
    kind, _m, obj = res["paths"][path]
    if kind == "link":
        return f"-> {obj if isinstance(obj, str) else obj.target}\n"
    text = obj.content if obj.content is not None else Path(obj.source_file).read_text()
    for k, v in res["vars"].get(path, {}).items():
        text = text.replace(k, v)
    return text


def verify_paths(res: dict) -> None:
    for path, (kind, mod, obj) in sorted(res["paths"].items()):
        if not path.startswith("/"):
            res["errors"].append(f"{mod}: target not absolute: {path}")
        src = {"file": getattr(obj, "source_file", None),
               "dir": getattr(obj, "source_directory", None),
               "link": obj if isinstance(obj, str) else getattr(obj, "target", None)}[kind]
        if src and kind != "link" and not os.path.exists(src):
            res["errors"].append(f"{mod}: {path}: source missing: {src}")
        if kind == "link" and src.startswith(str(REPO)) and not os.path.exists(src):
            res["errors"].append(f"{mod}: {path}: link target missing: {src}")
    for c in res["custom"]:
        pb = Path(c.pkgbuild_directory or "") / "PKGBUILD"
        if c.pkgbuild_directory and not pb.exists():
            res["errors"].append(f"custom {c.pkgname}: no {pb}")
        elif c.pkgbuild_directory:
            m = re.search(r"^pkgname=(\S+)", pb.read_text(), re.M)
            if not m or m.group(1).strip("'\"") != c.pkgname:
                res["errors"].append(f"custom {c.pkgname}: PKGBUILD pkgname mismatch")


# ------------------------------------------------------------------ packages


def _db_names(url: str, name: str) -> set[str]:
    CACHE.mkdir(parents=True, exist_ok=True)
    db = CACHE / name
    if not db.exists() or time.time() - db.stat().st_mtime > 86400:
        fetch(url, db)
    out = set()
    with tarfile.open(db) as t:
        for m in t:
            if m.name.endswith("/desc"):
                lines = t.extractfile(m).read().decode().splitlines()
                out.add(lines[lines.index("%NAME%") + 1])
    return out


def repo_index(host) -> dict[str, str]:
    """package -> repo for what this host's pacman.conf can see."""
    from lib import CACHYOS_MARCH, cachyos_repos  # stub is installed by now

    idx: dict[str, str] = {}
    for repo in ("core", "extra", "multilib"):
        for n in _db_names(f"{MIRROR}/{repo}/os/x86_64/{repo}.db", f"{repo}.db"):
            idx[n] = repo
    if host.cachyos:
        mdir = CACHYOS_MARCH[host.march][2]
        for repo, _ml in cachyos_repos(host.march):
            d = "x86_64" if repo == "cachyos" else mdir
            for n in _db_names(f"{CACHYOS_MIRROR}/{d}/{repo}/{repo}.db", f"{repo}.db"):
                idx[n] = repo
    return idx


def aur_info(names: set[str]) -> dict[str, dict]:
    out, names = {}, sorted(names)
    for i in range(0, len(names), 100):
        q = "&".join("arg[]=" + urllib.parse.quote(n) for n in names[i:i + 100])
        out.update({x["Name"]: x for x in json.loads(fetch(f"https://aur.archlinux.org/rpc/v5/info?{q}"))["results"]})
    return out


def verify_packages(res: dict, idx: dict[str, str], aur: dict[str, dict]) -> list[str]:
    warn = []
    for p in sorted(res["pacman"]):
        if p not in idx:
            res["errors"].append(f"pacman: {p} not in core/extra/multilib" + (" (it's in AUR)" if p in aur else ""))
    for p in sorted(res["aur"]):
        if p in idx:
            res["errors"].append(f"aur: {p} is in official repo {idx[p]} — move to pacman")
        elif p not in aur:
            res["errors"].append(f"aur: {p} not found")
        elif aur[p].get("OutOfDate"):
            warn.append(f"aur: {p} flagged out-of-date")
    return warn


# ------------------------------------------------------------------ main


def main() -> int:
    argv = sys.argv[1:]
    show = None
    if "--show" in argv:
        i = argv.index("--show")
        show = argv[i + 1]
        del argv[i:i + 2]
    args = [a for a in argv if not a.startswith("-")]
    verbose = "-v" in sys.argv
    hosts = args or sorted(p.stem for p in (HERE / "hosts").glob("*.py") if p.stem != "__init__")
    results = {}
    for h in hosts:
        res = collect(load_host(h))
        verify_paths(res)
        results[h] = res

    warns: list[str] = []
    if "--packages" in sys.argv:
        aur = aur_info(set().union(*(r["pacman"] | r["aur"] for r in results.values())))
        for r in results.values():
            warns += verify_packages(r, repo_index(r["host"]), aur)

    if show:
        for h, r in results.items():
            print(f"== {h}: {show}")
            print(render(r, show) if show in r["paths"] else "   (not managed on this host)\n")
        return 0

    ok = True
    for h, r in results.items():
        kinds = {k: sum(1 for v in r["paths"].values() if v[0] == k) for k in ("file", "dir", "link")}
        uu = sum(len(s) for s in r["user_units"].values())
        hh = r["host"]
        distro = f"{hh.distro}/{hh.march}" if hh.cachyos else hh.distro
        print(f"== {h} ({distro}, {hh.bootloader}): {len(r['modules'])} modules, {len(r['pacman'])} pacman + {len(r['aur'])} aur + "
              f"{len(r['custom'])} custom pkgs, {len(r['units'])} units + {uu} user units, "
              f"{kinds['file']} files, {kinds['link']} links")
        for u, g in r["extra_groups"].items():
            print(f"   user {u}: +groups {','.join(sorted(g))}")
        for u in r["users"]:
            print(f"   user {u.username}: groups={','.join(u.groups) or '-'} shell={u.shell}")
        if verbose:
            print("   pacman:", " ".join(sorted(r["pacman"])))
            print("   aur:   ", " ".join(sorted(r["aur"])))
            print("   custom:", " ".join(sorted(c.pkgname for c in r["custom"])))
            print("   units: ", " ".join(sorted(r["units"])))
            for u, s in r["user_units"].items():
                print(f"   user units ({u}):", " ".join(sorted(s)))
            for p, (k, m, _o) in sorted(r["paths"].items()):
                print(f"   {k:4} {p}  [{m}]")
        for e in r["errors"]:
            ok = False
            print(f"   ERROR {e}")
    for w in sorted(set(warns)):
        print(f"   warn  {w}")
    print("OK" if ok else "FAILED")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
