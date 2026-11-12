# sys-cfg

System config and dotfiles for my machines (`nixos` — desktop, `laptop`).

```
nix/        NixOS + Home Manager flake — what runs now
decman/     the same system for Arch, as decman (Python) modules
dotfiles/   plain config files, used by both
etc/        system files decman copies into /etc
pkgbuilds/  PKGBUILDs for packages not in the AUR
```

- NixOS: `sudo nixos-rebuild switch --flake ~/sys-cfg/nix` (see `nix/README.md`).
- Arch: `sudo decman --source ~/sys-cfg/decman/source.py`.
- Check the decman side offline: `python3 decman/check.py [host] [-v] [--packages]`.
- Migration status, decisions and TODOs: [MIGRATION.md](MIGRATION.md).

## decman layout

```
decman/
  source.py            entry point: picks the host, adds modules
  hosts/<name>.py      HOST = lib.Host(hostname, username, mounts, extra_modules)
  lib/                 paths, SysModule base, link/link_tree/user_file/etc_file, PackageSet
  modules/
    __init__.py        COMMON module list (order = hook order)
    core/ hardware/ desktop/ programs/ theme/ packages/
```

A module is a `lib.SysModule` subclass with a `NAME` and a `module(host)`
factory; packages/units come from decman's plugin decorators
(`@pacman.packages`, `@aur.packages`, `@systemd.units`, `@systemd.user_units`),
files from `files()` / `symlinks()`. Plain package lists use
`lib.packages.PackageSet`. Groups for the main user: override `groups()`.
