# nix (sys-cfg)

Declarative config for multiple machines: NixOS (system) + Home Manager (user),
driven by one flake. Lives in `nix/` of the `~/sys-cfg` monorepo
(github.com/imizgun/sys-cfg), next to `dotfiles/`. Always pass
`--flake ~/sys-cfg/nix` — `/etc/nixos` is not used.

Each host gets its own `nixosConfigurations.<hostname>` entry in `flake.nix`, which
also pins that host's username. Every other module reads `hostname`/`username` via
`specialArgs` instead of hardcoding either — see "Adding a new host" below.

## Layout

```
flake.nix                           inputs, and the per-host hostname/username list
hosts/<hostname>/
  configuration.nix                 host entry point: imports system modules
  hardware-configuration.nix        machine-specific, generated — don't hand-edit

modules/system/                     things that apply system-wide, need root, or
                                     must exist before/outside a user session
  core/                             boots, networks, and identifies the machine
    boot.nix                       bootloader
    networking.nix                 hostname (from specialArgs), NetworkManager
    locale.nix                     timezone, i18n, keyboard layout
    users.nix                      the primary user account (from specialArgs), login shell
    nix.nix                        flakes, allowUnfree, garbage collection
  hardware/                        device-level enablement
    audio.nix                      PipeWire + rtkit
    bluetooth.nix                  hardware.bluetooth
  E/                         the graphical session
    niri.nix                       niri (compositor), greetd (login manager), dconf
  packages.nix                     CLI tools every account on the machine gets

modules/home/                       everything that runs as your user
  home.nix                         entry point, imports the rest
  programs/                        declaratively-configured CLI tools
    fish.nix / kitty.nix / helix.nix   programs.<name>.enable — Home Manager owns
                                        the dotfiles for these declaratively
  desktop/
    niri.nix                       symlinks dotfiles/niri into ~/.config/niri
  theme/                           appearance, shared across GTK/niri/cursor
    cursor.nix                     home.pointerCursor (capitaine-cursors)
    gtk.nix                        GTK theme/icons/dark-mode for Nautilus etc.
  packages.nix                     GUI apps and CLI tools you just want on PATH
```

Dotfiles live in `../dotfiles/` of the same repo; `modules/home/desktop/niri.nix`
points at `dotfiles/niri` by relative path. Edit niri's KDL files there; a rebuild
picks up the change. Only git-tracked files are visible to the flake — `git add`
new files before rebuilding. The noctalia settings in `dotfiles/noctalia/` (bar widgets, colorscheme, wallpaper
config) are still in v4's JSON schema and are **not** wired into this system —
noctalia v5 uses TOML with a different schema entirely, so that's unmigrated. Niri's
keybinds/rules/autostart *are* migrated to v5 (`noctalia msg ...` IPC, v5 layer-shell
namespaces).

## The rule for "how do I install X?"

- **A single app you just want available** (browser, chat client, CLI tool, editor
  with no need for declarative dotfiles) → add one line to
  `modules/home/packages.nix`, then rebuild (see below). This is the common case —
  `telegram-desktop`, `zen-browser`, `zed-editor`, `firefox` all live here.
- **Something you want Home Manager to manage the config file for** (currently fish,
  kitty, helix) → give it its own `modules/home/programs/<name>.nix` with
  `programs.<name>.enable = true;` and whatever settings you want under that same
  `programs.<name>.*` namespace, then add it to the `imports` list in `home.nix`.
- **Something that needs root, runs before login, or must be available to every user
  on the machine** (rare on a single-user laptop/desktop) → add it to
  `environment.systemPackages` in `modules/system/packages.nix`, or give it its own
  file under `modules/system/core/`, `hardware/`, or `desktop/` — whichever category
  fits — if it's a whole subsystem (a new service, etc.). Adding a fourth category
  under `modules/system/` or `modules/home/` is fine once something clearly doesn't
  fit `core`/`hardware`/`desktop`/`programs`/`theme` — don't force a fit.

Package names: search with `nix search nixpkgs <name>`. Everything in nixpkgs is
fair game for either `home.packages` or `environment.systemPackages`.

## Day to day

`nixos-rebuild` infers the right flake output from the machine's actual hostname, so
the same commands work unchanged on any host this flake knows about (currently
`nixos` and `laptop`) — no need to pass `#<hostname>` unless building for a machine
other than the one you're on.

```sh
# after editing any .nix file (or dotfiles/) — apply the change
sudo nixos-rebuild switch --flake ~/sys-cfg/nix

# check for eval errors without touching the running system
nixos-rebuild build --flake ~/sys-cfg/nix

# pull newer versions of nixpkgs / home-manager / zen-browser
nix flake update --flake ~/sys-cfg/nix

# see what changed before committing an update
git -C ~/sys-cfg diff nix/flake.lock
```

## Adding a new host

1. Add an entry to `nixosConfigurations` in `flake.nix`:
   `<name> = mkHost { hostname = "<name>"; username = "<user>"; };`
2. Create `hosts/<name>/configuration.nix` (copy an existing host's file — it's just
   the module import list).
3. Generate `hosts/<name>/hardware-configuration.nix` **on that machine**
   (`nixos-generate-config`, or it's already there if NixOS was installed on it) and
   copy it in — it's UUID/filesystem-specific and can't be written by hand or reused
   from another host.

Always run `build` before `switch` when you've made a change you're not sure
about — it does the full evaluation and build but never touches your running system.

## If a rebuild breaks something

NixOS never overwrites your previous working system. Every `switch` adds a new boot
entry and keeps the old ones. If something's broken after a rebuild:

- **Still logged in?** `sudo nixos-rebuild switch --rollback` goes back to the
  previous generation immediately.
- **Can't boot?** Reboot, and at the systemd-boot menu pick the older "NixOS -
  Configuration N" entry. That boots the exact previous generation, untouched.

Nothing here is destructive — worst case you lose a few minutes rolling back.

## Why this structure

- Everything is one git repo in your home directory (`git -C ~/sys-cfg log`),
  so config history is `git log`, not "which file did I edit three weeks ago."
- `flake.lock` pins exact commits of nixpkgs/home-manager/zen-browser, so
  `nixos-rebuild switch` always builds the same thing until you explicitly
  `nix flake update` — no surprise upgrades from a channel changing under you.
- System vs. home is split because they have different blast radii: system modules
  need `sudo` and affect every account on the machine; home modules are yours alone
  and Home Manager can rebuild just your profile without touching the system if you
  ever want that (`home-manager switch` directly, though on NixOS the combined
  `nixos-rebuild switch` above already does both in one step).
