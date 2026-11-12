# NixOS → Arch (decman) migration

Status: `nix/` is live (this is what runs now). `decman/` is a full port that
passes `python3 decman/check.py --packages`, but has **not been run on Arch
yet**. Next step: a test run in an Arch VM (see the end of this file).

## Where things went

| nix/ | decman/ | Notes |
|---|---|---|
| `flake.nix` `mkHost` | `hosts/<hostname>.py` → `lib.Host` | picked by `socket.gethostname()` or `SYSCFG_HOST` |
| `modules/system/packages.nix` | `core/base.py` | + base, kernel, firmware, ucode (decman removes anything undeclared) |
| `core/boot.nix` | `core/boot.py` | `bootctl install` once; loader entries are install-time |
| `core/locale.nix` | `core/locale.py` | xkb layout is in `dotfiles/niri/cfg/input.kdl` |
| `core/networking.nix` | `core/networking.py` | |
| `core/users.nix` | `core/users.py` | groups gathered from modules' `groups()` |
| `core/nix.nix` | `core/pacman.py` | gc → `paccache.timer`; multilib on; overlays dropped (below) |
| `hardware/audio.nix` | `hardware/audio.py` | |
| `hardware/bluetooth.nix` | `hardware/bluetooth.py` + `etc/bluetooth/main.conf` | |
| `hardware/power.nix` | `hardware/power.py` | |
| `hardware/storage.nix` | `hardware/storage.py` | `/mnt/sda1` as a `.mount` unit, `nixos` host only |
| `hardware/snapshots.nix` | `hardware/snapshots.py` + `etc/snapper/`, timer drop-in | + new: `/` pre/post snapshots via snap-pac (replaces NixOS generations, see below) |
| `hardware/udev.nix` | `hardware/udev.py` | `qmk` (ships udev rules), `via-bin` |
| `hardware/virtualisation.nix` | `hardware/virt.py` | |
| `desktop/niri.nix` (system+home) | `desktop/niri.py` + `etc/greetd/config.toml` | portals/keyring that NixOS pulled implicitly are explicit |
| `desktop/steam.nix` (system+home) | `desktop/steam.py` + `dotfiles/applications/steam.desktop` | Millennium from AUR |
| `desktop/xwayland.nix` | `desktop/niri.py` | |
| `home/desktop/font.nix` | `desktop/fonts.py` | |
| `home/home.nix` sessionVariables | `desktop/session.py` + `dotfiles/environment.d/` | |
| `home/desktop/noctalia.nix` | `desktop/noctalia.py` | |
| `home/programs/*.nix` | `programs/*.py` | |
| `home/theme/gtk.nix` | `theme/gtk.py` + `dotfiles/gtk/` + `etc/dconf/` | color-scheme via system dconf db |
| `home/theme/cursor.nix` | `theme/cursor.py` + `dotfiles/cursor/` | |
| vicinae (was GUI-only) | `programs/vicinae.py` + `dotfiles/vicinae/sys-cfg.json` | store extensions installed by the module; settings.json imports sys-cfg.json |
| `home/packages.nix` | `packages/{browsers,dev,apps}.py`, host-only `packages/{games,photo}.py` | |
| flake inputs zen/nls/sonora/millennium | AUR `zen-browser-bin`, `nls-bin`, `sonora-bin`, `millennium` | nls/sonora AUR pkgs are by their upstream author |
| flake inputs ricture, wayzoomy | `pkgbuilds/{ricture,wayzoomy}-git` | built by `packages/custom.py` |
| `pkgs/deadlock-mod-manager.nix` | AUR `deadlock-modmanager-bin` | |

## Behavior changes / decisions

- **decman removes explicitly installed packages that no module declares.**
  `pacman -S foo` by hand gets reverted on the next run — add it to a module
  (or to `decman.pacman.ignored_packages`).
- **Dotfiles are symlinked per file** (`lib.link`, `lib.link_tree`): edits in
  the repo are live without re-running decman, and files apps write next to
  their config (`fish_variables`, …) stay out of the repo. Units, `.desktop`
  and `/etc` files are **copied** (`lib.user_file`, `lib.etc_file`) — re-run
  decman after editing those.
- Kernel: `linux` on both hosts (NixOS: pinned latest on the PC, nixpkgs LTS
  on the laptop). The laptop note about BlueZ on 6.12 doesn't apply to current
  `linux`; switch to `linux-lts` per host if needed.
- `dialout` → `uucp` (Arch's serial-port group); `libvirtd` group → `libvirt`.
- `/mnt/sda1` was in the shared NixOS module (with `nofail`) — it's the PC's
  disk, so it's now only in `hosts/nixos.py`, as `.automount` (mounted on
  first access; a missing disk doesn't delay boot, like `nofail`).
- .NET 11: only RC in AUR (`dotnet-sdk-preview-bin`); `extra` has 10.
  `dotnet-ef` → `dotnet tool install --global dotnet-ef`.
- fish plugins: `fisher` + `dotfiles/fish/fish_plugins` (bass has no Arch pkg).
  starship/direnv hooks: `dotfiles/fish/arch/integrations.fish`.
- vicinae: `settings.json` stays a writable real file (the GUI rewrites it)
  and imports the repo's `sys-cfg.json`; the module creates it if missing.
  Store extensions are installed if missing (`STORE_EXTENSIONS`); the Raycast
  one (Google Translate) must be installed once from the UI — vicinae
  re-bundles Raycast zips on install. The `nix` extension is not carried over.
- `JAVA_HOME=/usr/lib/jvm/default` (archlinux-java's symlink) in environment.d.
- AUR builds run as `builduser` (home in `/var/lib/builduser`) — cargo-based
  PKGBUILDs need a writable `$HOME`.

### NixOS defaults made explicit

Things NixOS does without being asked, found by diffing the live system
(enabled units, system profile), not the .nix files:

- packages: `openssh`, `less`, `which`, `rsync`, `strace`, `xdg-utils`,
  `dosfstools`, `e2fsprogs` (core.base)
- services: `systemd-timesyncd`, `fstrim.timer`, `systemd-oomd` (core.base),
  `libvirt-guests` (hardware.virt)
- firewall: inbound default-deny via nftables (core.firewall, `etc/nftables.conf`);
  only `inet filter` is managed, libvirt's NAT tables are left alone
- ssh-agent: `gcr-ssh-agent.socket` + `SSH_AUTH_SOCK` (desktop.niri, environment.d)
- bluetooth OBEX (`bluez-obex`), SPICE USB redirection (`spice-gtk`)

Deliberately not carried over: ModemManager (no modem), speech-dispatcher,
nscd, logrotate (journald), the swap partitions (fstab, install-time).
Pre-existing: `dotfiles/niri/cfg/keybinds.kdl` still binds `tokativ`, which
was removed from the NixOS packages earlier.

### Dropped with Nix

`nix-ld`, `nix-direnv`, `nil`, `nixd`, the `nix develop` fish wrapper and
`nix-rebuild`/`nix-update` aliases, the jetbrains-mono overlay (use
`ttf-jetbrains-mono`), the espup aws-lc overlay, discord from nixpkgs-master,
`kitty-themes` (Nord is vendored), Steam FHS `breeze` extraPkg.

## To verify on a real Arch (VM first)

- [ ] `ghostty` package ships `app-com.mitchellh.ghostty.service` (user unit).
- [ ] User units: decman enables them with `systemctl --user -M <user>@`, which
      needs the user's manager running — first run after logging in once (or
      `loginctl enable-linger`).
- [ ] libvirt: NixOS had `runAsRoot = false`; check `/etc/libvirt/qemu.conf`
      `user`/`group` defaults on Arch.
- [ ] Millennium patches Arch's `steam` correctly; Steam cursor without breeze.
- [ ] `qmk`/`via-bin` udev rules: flashing and VIA see the keyboard.
- [ ] `tuigreet --remember` works (greetd-tuigreet's cache dir).
- [ ] Snapper with the partial config (as NixOS generated it).
- [ ] `ricture-git` / `wayzoomy-git` build via decman.

## Rolling back /

NixOS generations are replaced by snapper snapshots of `/`: snap-pac takes a
pre/post pair around every pacman transaction (so every decman run), the last
10 are kept. `snapper -c root list` shows them; `snapper -c root status N..M`
/ `undochange N..M` reverts individual files while the system still works.

Full rollback when it doesn't boot (systemd-boot can't boot snapshots, so
from the Arch ISO):

```sh
mount -o subvolid=5 /dev/<root-partition> /mnt     # btrfs top level
mv /mnt/@ /mnt/@.broken
btrfs subvolume snapshot /mnt/@.snapshots/<N>/snapshot /mnt/@
```

**The ESP isn't in the snapshot** (`/boot` is FAT): if the bad transaction
updated the kernel, the restored `/` has the old modules but `/boot` the new
kernel. Before rebooting: `arch-chroot` into the restored root (mount `/boot`)
and run `pacman -S linux` to put the matching kernel + initramfs back.
Delete `@.broken` once everything works.

## Testing in a VM

- Use **vanilla Arch** (archinstall), not CachyOS: CachyOS ships its own repos
  in pacman.conf and many explicitly installed packages (`linux-cachyos`,
  `cachyos-settings`, …). decman would overwrite pacman.conf and **remove**
  every explicit package the config doesn't declare — including the kernel
  the VM boots. A CachyOS target needs its own core modules.
- Always start with `sudo decman --source ~/sys-cfg/decman/source.py --dry-run`
  and read what it would remove.
- Host: name the VM `laptop` or `nixos`, or `sudo SYSCFG_HOST=laptop decman …`.
  The user must match the host's `username` (laptop: `imizgun`, nixos: `vkabaczko`).

## Not managed (install-time, once)

Partitioning and btrfs subvolumes (`@`, `@home`, …), `/etc/fstab`
(`genfstab`), systemd-boot loader entries + kernel cmdline, mirrorlist,
passwords (`passwd`), hostname matching a `decman/hosts/<name>.py`.

## Install order (when the time comes)

1. Base install (archinstall or manual): btrfs, systemd-boot, `base linux
   linux-firmware amd-ucode base-devel git`, user `vkabaczko` (uid 1000) in `wheel`.
2. `git clone https://github.com/imizgun/sys-cfg ~/sys-cfg`
3. Bootstrap decman from AUR by hand once (`git clone
   https://aur.archlinux.org/decman.git && makepkg -si`).
4. `python3 ~/sys-cfg/decman/check.py --packages`, then a `--dry-run`
5. `sudo decman --source ~/sys-cfg/decman/source.py` (later runs: `sudo decman`).
6. Log in, run `sudo decman` again (user units), `fisher update` if needed.
7. `mv ~/.local/state/noctalia/settings.toml{,.bak}` if it shadows the repo config.

Hostnames: `nixos` is kept for continuity with `nix/`; renaming the PC means
renaming `decman/hosts/nixos.py` and `dotfiles/noctalia/hosts/nixos.toml`.
