# nix (sys-cfg)

NixOS + Home Manager for both machines, one flake. Lives in `nix/` of the
`~/sys-cfg` monorepo next to `dotfiles/` (plain config files the modules link
into place). `/etc/nixos` is not used.

## Day to day (nh)

`programs.nh.flake` points `NH_FLAKE` at this directory, so no `--flake` needed.

```sh
nh os switch               # build, show what changes, activate   (alias: nix-rebuild)
nh os switch --update      # nix flake update first               (alias: nix-upgrade)
nh os build                # build only, never touches the running system
nh os test                 # activate now, but no boot entry (gone after reboot)
nh os switch --ask         # show the diff and ask before activating
nh search <name>           # search nixpkgs
nh clean all --keep 3      # by hand; also runs weekly (core/nix.nix)

nix flake update zen-browser   # update one input only
git diff flake.lock            # what an update moved
```

Only git-tracked files are visible to the flake: `git add` new files first.

**If something breaks:** `nh os rollback` (previous generation), or pick an
older "NixOS - Configuration N" entry in the boot menu. `nh os info` lists
generations.

## Layout

Grouped by category. Each file is **one feature, system and
user side together**: system options at the top level, Home Manager options
under `hm.*` (alias for `home-manager.users.<username>`, see `core/home.nix`).

```
flake.nix                 inputs; host list (hostname/username); packages output
hosts/<host>/
  default.nix             imports ../../modules + host-only modules, host bits
  hardware-configuration.nix   generated on that machine — don't hand-edit
modules/
  default.nix             modules every host gets
  core/                   nix (+nh, overlays), home (HM setup), boot, locale, networking, users
  hardware/               audio, bluetooth, power, storage, snapshots, udev, virt
  desktop/                session, niri, noctalia, fonts
  programs/               fish, ghostty, nautilus, helix, direnv, jdk, kitty, vicinae, steam
  theme/                  gtk, cursor
  packages/               plain package lists: base (system), browsers, dev, apps,
                          games (PC only), photo (laptop only)
overlays/
  default.nix             own packages → pkgs.*, pkgs.master, fixes
  fixes.nix               patched nixpkgs packages (each says when it can go)
pkgs/
  <name>.nix              own packages → pkgs.<name>
```

A module looks like:

```nix
{ pkgs, dotfiles, ... }:
{
  programs.niri.enable = true;                         # system
  hm.home.packages = [ pkgs.xwayland-satellite ];      # user
  hm.xdg.configFile."niri".source = "${dotfiles}/niri";
}
```

Module arguments: `pkgs`, `lib`, `config`, plus `inputs`, `hostname`,
`username`, `dotfiles` (flake.nix `specialArgs`). Inside `hm = { config, ... }:
{ ... }` the `config` is Home Manager's.

## How do I…

**…install an app?** One line in the fitting `modules/packages/*.nix`. Search:
`nh search <name>` or search.nixos.org. If the app needs config files or a
service, give it its own `modules/programs/<name>.nix` and add it to
`modules/default.nix`. Only for one host → import it in `hosts/<host>/default.nix`.

**…get a newer version than unstable has?** In order of effort:

1. `pkgs.master.<name>` — the package from nixpkgs master (already merged, not
   yet in unstable, typically days behind). Replace `discord` with
   `master.discord` in the list. Go back once unstable catches up.
2. Bump the version yourself in `overlays/fixes.nix`:
   ```nix
   obsidian = prev.obsidian.overrideAttrs (old: rec {
     version = "1.9.0";
     src = final.fetchurl {
       url = "https://github.com/obsidianmd/obsidian-releases/releases/download/v${version}/obsidian-${version}.tar.gz";
       hash = "";   # build once, copy the "got: sha256-…" from the error
     };
   });
   ```
   Works for most "only the source changed" updates. Rust/Go packages also
   need `cargoHash` / `vendorHash` the same way (for Rust:
   `cargoDeps = final.rustPlatform.fetchCargoVendor { inherit (finalAttrs) src; hash = ""; }`).
3. Upstream ships a flake → add it to `inputs` in flake.nix and use
   `inputs.<name>.packages.${system}.default` (like zen-browser, sonora). It
   follows upstream, `nix flake update <name>` pulls the latest.

**…add something that's not in nixpkgs and has no flake?** Write a package in
`pkgs/<name>.nix` — it becomes `pkgs.<name>` automatically (overlays/default.nix)
and `nix build .#<name>` builds just it. Templates:

- prebuilt binary / .deb / AppImage → `pkgs/deadlock-mod-manager.nix`
  (`autoPatchelfHook` fixes the library paths). AppImage: `appimageTools.wrapType2`.
- from source: `rustPlatform.buildRustPackage`, `buildGoModule`,
  `python3Packages.buildPythonApplication`, `stdenv.mkDerivation` (make/cmake/meson).
  Copy the closest package from nixpkgs (`nix edit nixpkgs#<similar>`) and adapt.
- updating it later: `nix run nixpkgs#nix-update -- --flake <name>` (bumps
  version + hashes to the latest GitHub release), or
  `--version=branch` for git master.
- a repo you want to track by `nix flake update` instead of by version:
  add `inputs.<name> = { url = "github:owner/repo"; flake = false; };` and use
  `src = inputs.<name>;` in the package (pass `inputs` via `callPackage`).

`hash = "";` + build + copy the hash from the error is the normal workflow for
every fetcher, not a hack.

**…run a binary that wants a normal Linux?** It usually just works thanks to
`programs.nix-ld` (core/nix.nix). Otherwise `steam-run ./binary`, or package it.

**…try a package without installing?** `nix shell nixpkgs#<name>`, or
`nix run nixpkgs#<name>`. A dev shell for a project: `flake.nix` with
`devShells` + `.envrc` with `use flake` (direnv is set up).

## Adding a new host

1. flake.nix: `<name> = mkHost { hostname = "<name>"; username = "<user>"; };`
2. `hosts/<name>/default.nix` — copy an existing one.
3. `hosts/<name>/hardware-configuration.nix` — generate **on that machine**
   (`nixos-generate-config --show-hardware-config`).

## Debugging

- Evaluation errors: add `--show-trace`; the last frames that mention a file of
  this repo are the ones that matter.
- What is an option set to? `nh os repl` →
  `config.services.greetd.settings`, `config.hm.home.packages`, `pkgs.discord.version`.
- Option docs: search.nixos.org/options (NixOS),
  home-manager-options.extranix.com (Home Manager), `man configuration.nix`.
- Build log of a failed package: `nix log /nix/store/<…>.drv` (the path is in the error).
