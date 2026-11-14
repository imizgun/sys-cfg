{ pkgs, ... }:

# PC only (hosts/nixos). Steam itself: programs/steam.nix.
{
  hm.home.packages = with pkgs; [
    deadlock-mod-manager # own package, pkgs/deadlock-mod-manager.nix
    supertuxkart
    bluez
  ];
}
