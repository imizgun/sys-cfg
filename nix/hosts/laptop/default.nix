{ pkgs, ... }:

# The laptop. Common modules + laptop-only ones.
{
  imports = [
    ./hardware-configuration.nix
    ../../modules
    ../../modules/packages/photo.nix
  ];

  # This value determines the NixOS release from which the default settings
  # for stateful data were taken. Leave it at the release of the first
  # install of this system — see configuration.nix(5).
  system.stateVersion = "26.05";

  # Newest kernel nixpkgs has (the PC uses the default LTS).
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
