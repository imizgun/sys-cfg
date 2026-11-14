# nixpkgs overlays, applied to the system's (and Home Manager's) pkgs.
#
# An overlay is `final: prev: { name = ...; }`: `prev` is nixpkgs before this
# overlay, `final` is the end result (use it for dependencies). Whatever you
# define here becomes `pkgs.<name>` everywhere — and if you replace an existing
# name, other packages that depend on it get your version too.
{ inputs }:

[
  # pkgs.millennium-steam (programs/steam.nix)
  inputs.millennium.overlays.default

  # Own packages: every pkgs/<name>.nix (or pkgs/<name>/package.nix) becomes
  # pkgs.<name>, like nixpkgs' pkgs/by-name.
  (final: prev:
    prev.lib.packagesFromDirectoryRecursive {
      inherit (final) callPackage;
      directory = ../pkgs;
    })

  # pkgs.master.<name>: a single package from nixpkgs master, for when
  # unstable lags behind (master is ahead by ~days; nothing is cached for it
  # until Hydra builds it, so big packages may compile locally).
  (final: prev: {
    master = import inputs.nixpkgs-master {
      inherit (final.stdenv.hostPlatform) system;
      config = final.config;
    };
  })

  # Fixes for broken nixpkgs packages. Each one says when it can go.
  (import ./fixes.nix)
]
