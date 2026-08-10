{
  description = "vkabaczko's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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
  };


  outputs = { self, nixpkgs, home-manager, zen-browser, ... }@inputs:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/nixos/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.vkabaczko = import ./modules/home/home.nix;
            # Pre-existing plain files (from before this repo managed them) get
            # renamed to *.hm-bak instead of aborting the switch.
            home-manager.backupFileExtension = "hm-bak";
          }
        ];
      };
    };
}
