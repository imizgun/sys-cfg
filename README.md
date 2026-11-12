# sys-cfg

System config and dotfiles for my machines (`nixos` — desktop, `laptop`).
Currently NixOS; moving to CachyOS managed by decman (see MIGRATION.md).

```
nix/        NixOS + Home Manager flake — what runs now
decman/     the same system for Arch, as decman (Python) modules
dotfiles/   plain config files, used by both
etc/        system files decman copies into /etc
pkgbuilds/  PKGBUILDs for packages not in the AUR
```

- NixOS: `sudo nixos-rebuild switch --flake ~/sys-cfg/nix` (see `nix/README.md`).
- CachyOS / Arch: `sudo decman --source ~/sys-cfg/decman/source.py`.
- Check the decman side offline: `python3 decman/check.py [host] [-v] [--packages]`.
- Migration status, decisions and TODOs: [MIGRATION.md](MIGRATION.md).

## decman layout

```
decman/
  source.py            entry point: picks the host, adds modules
  hosts/<name>.py      HOST = lib.Host(hostname, username, distro, march, bootloader, ...)
  lib/                 paths, SysModule base, link/link_tree/user_file/etc_file, PackageSet
  modules/
    __init__.py        COMMON module list (order = hook order)
    core/ hardware/ desktop/ programs/ theme/ packages/
```

A module is a `lib.SysModule` subclass plus a `module(host)` factory; its
decman name comes from the file path (`modules/core/boot.py` → `core.boot`, the
same key `modules/__init__.py` lists). Packages/units come from decman's plugin
decorators (`@pacman.packages`, `@aur.packages`, `@systemd.units`,
`@systemd.user_units`), files from `files()` / `symlinks()`. Plain package
lists subclass `lib.packages.PackageSet` with `PACMAN` / `AUR` sets. Groups for
the main user: override `groups()`.
