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
| `hardware/snapshots.nix` | `hardware/snapshots.py` + `etc/snapper/`, timer drop-in | |
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
  disk, so it's now only in `hosts/nixos.py`.
- .NET 11: only RC in AUR (`dotnet-sdk-preview-bin`); `extra` has 10.
  `dotnet-ef` → `dotnet tool install --global dotnet-ef`.
- fish plugins: `fisher` + `dotfiles/fish/fish_plugins` (bass has no Arch pkg).
  starship/direnv hooks: `dotfiles/fish/arch/integrations.fish`.
- `JAVA_HOME` isn't exported; `archlinux-java` manages the default JDK.
- AUR builds run as `builduser` (home in `/var/lib/builduser`) — cargo-based
  PKGBUILDs need a writable `$HOME`.

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
4. `python3 ~/sys-cfg/decman/check.py --packages`
5. `sudo decman --source ~/sys-cfg/decman/source.py` (later runs: `sudo decman`).
6. Log in, run `sudo decman` again (user units), `fisher update` if needed.
7. `mv ~/.local/state/noctalia/settings.toml{,.bak}` if it shadows the repo config.

Hostnames: `nixos` is kept for continuity with `nix/`; renaming the PC means
renaming `decman/hosts/nixos.py` and `dotfiles/noctalia/hosts/nixos.toml`.
