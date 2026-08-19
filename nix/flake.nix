{
  description = "Personal NixOS configuration (multiple hosts/users)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    kernel-nixpkgs.url = "github:NixOS/nixpkgs/148bab9";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nls.url = "github:nolight132/nls";

    sonora.url = "github:nolight132/sonora";

    ricture = {
      url = "github:imizgun/ricture";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };


  outputs = { self, nixpkgs, home-manager, zen-browser, ... }@inputs:
    let
      # Each host names its own hostname/username here — that's the single
      # place they're defined, everything else reads them via specialArgs.
      mkHost = { hostname, username }:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs hostname username; };
          modules = [
            ./hosts/${hostname}/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs username; };
              home-manager.users.${username} = import ./modules/home/home.nix;
              # Pre-existing plain files (from before this repo managed them) get
              # renamed to *.hm-bak instead of aborting the switch.
              home-manager.backupFileExtension = "hm-bak";
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        nixos = mkHost { hostname = "nixos"; username = "vkabaczko"; };
        laptop = mkHost { hostname = "laptop"; username = "imizgun"; };
      };
    };
}
