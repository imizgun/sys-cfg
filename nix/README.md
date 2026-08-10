# nixos-config

Declarative config for this machine: NixOS (system) + Home Manager (user), driven by
one flake. Lives in `~/nixos-config`; `/etc/nixos` is a symlink to this directory so
plain `nixos-rebuild` commands still work.

## Layout

```
flake.nix                           inputs: nixpkgs, home-manager, zen-browser
hosts/nixos/
  configuration.nix                 host entry point: imports system modules
  hardware-configuration.nix        machine-specific, generated — don't hand-edit
modules/system/                     things that apply system-wide, need root, or
                                     must exist before/outside a user session
  boot.nix                          bootloader
  networking.nix                    hostname, NetworkManager
  locale.nix                        timezone, i18n, keyboard layout
  users.nix                         the vkabaczko user account, login shell
  desktop.nix                       niri (compositor) + greetd (login manager)
  nix.nix                           flakes, allowUnfree, garbage collection
modules/home/                       everything that runs as your user
  home.nix                          entry point, imports the rest
  fish.nix / kitty.nix / helix.nix  programs.<name>.enable — Home Manager owns
                                     the dotfiles for these declaratively
  niri.nix                          niri's config.kdl, sourced from this repo
  packages.nix                      GUI apps and CLI tools you just want on PATH
```

## The rule for "how do I install X?"

- **A single app you just want available** (browser, chat client, CLI tool, editor
  with no need for declarative dotfiles) → add one line to
  `modules/home/packages.nix`, then rebuild (see below). This is the common case —
  `telegram-desktop`, `zen-browser`, `zed-editor`, `firefox` all live here.
- **Something you want Home Manager to manage the config file for** (currently fish,
  kitty, helix) → give it its own `modules/home/<name>.nix` with
  `programs.<name>.enable = true;` and whatever settings you want under that same
  `programs.<name>.*` namespace, then add it to the `imports` list in `home.nix`.
- **Something that needs root, runs before login, or must be available to every user
  on the machine** (rare on a single-user laptop/desktop) → add it to
  `environment.systemPackages` in `modules/system/desktop.nix`, or give it its own
  `modules/system/<name>.nix` if it's a whole subsystem (a new service, etc.).

Package names: search with `nix search nixpkgs <name>`. Everything in nixpkgs is
fair game for either `home.packages` or `environment.systemPackages`.

## Day to day

```sh
# after editing any .nix file — apply the change
sudo nixos-rebuild switch --flake ~/nixos-config#nixos

# check for eval errors without touching the running system
sudo nixos-rebuild dry-build --flake ~/nixos-config#nixos

# pull newer versions of nixpkgs / home-manager / zen-browser
nix flake update

# see what changed before committing an update
git -C ~/nixos-config diff flake.lock
```

Always run `dry-build` before `switch` when you've made a change you're not sure
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

- Everything is one git repo in your home directory (`git -C ~/nixos-config log`),
  so config history is `git log`, not "which file did I edit three weeks ago."
- `flake.lock` pins exact commits of nixpkgs/home-manager/zen-browser, so
  `nixos-rebuild switch` always builds the same thing until you explicitly
  `nix flake update` — no surprise upgrades from a channel changing under you.
- System vs. home is split because they have different blast radii: system modules
  need `sudo` and affect every account on the machine; home modules are yours alone
  and Home Manager can rebuild just your profile without touching the system if you
  ever want that (`home-manager switch` directly, though on NixOS the combined
  `nixos-rebuild switch` above already does both in one step).
