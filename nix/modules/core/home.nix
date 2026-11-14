{ inputs, lib, hostname, username, dotfiles, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    # `hm.<option>` = `home-manager.users.<username>.<option>`, so a module
    # can set system and user options side by side.
    (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" username ])
  ];

  home-manager = {
    # HM uses the system's pkgs (same nixpkgs, overlays, allowUnfree).
    useGlobalPkgs = true;
    # User packages go to /etc/profiles/per-user/<user>, not ~/.nix-profile.
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs hostname username dotfiles; };
    # Pre-existing plain files (from before this repo managed them) get
    # renamed to *.hm-bak instead of aborting the switch.
    backupFileExtension = "hm-bak";
  };

  hm = {
    home.username = username;
    home.homeDirectory = "/home/${username}";

    # Matches system.stateVersion in hosts/*/default.nix — do not bump this on
    # new NixOS releases, it pins Home Manager's own defaults to what this
    # profile was created with.
    home.stateVersion = "26.05";

    programs.home-manager.enable = true;
  };
}
