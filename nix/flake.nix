{
  description = "Personal NixOS configuration (multiple hosts/users)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Bleeding edge, for single packages: `pkgs.master.<name>` (overlays/).
    # Only fetched/evaluated for packages that actually use it.
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Apps that ship their own flake (packages.<system>.default).
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nls.url = "github:nolight132/nls";
    sonora = {
      url = "github:sonorahq/sonora/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wayzoomy.url = "github:nolight132/wayzoomy";
    ricture = {
      url = "github:imizgun/ricture";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      # Each host names its hostname/username here — the single place they're
      # defined; every module reads them as module arguments.
      mkHost = { hostname, username }:
        nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs hostname username;
            # ../dotfiles of this repo: plain config files modules link into place.
            dotfiles = ../dotfiles;
          };
          modules = [ ./hosts/${hostname} ];
        };
    in
    {
      nixosConfigurations = {
        nixos = mkHost { hostname = "nixos"; username = "vkabaczko"; };
        laptop = mkHost { hostname = "laptop"; username = "imizgun"; };
      };

      # Own packages from pkgs/ (with the system's overlays applied), so they
      # can be built/updated alone: `nix build .#deadlock-mod-manager`,
      # `nix run nixpkgs#nix-update -- --flake deadlock-mod-manager`.
      packages.x86_64-linux =
        let pkgs = self.nixosConfigurations.nixos.pkgs; in
        nixpkgs.lib.packagesFromDirectoryRecursive {
          inherit (pkgs) callPackage;
          directory = ./pkgs;
        };
    };
}
