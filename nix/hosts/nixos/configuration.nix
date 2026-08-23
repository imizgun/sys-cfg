{ inputs, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    # core: boots, networks, and identifies the machine
    ../../modules/system/core/boot.nix
    ../../modules/system/core/networking.nix
    ../../modules/system/core/locale.nix
    ../../modules/system/core/users.nix
    ../../modules/system/core/nix.nix

    # hardware: device-level enablement
    ../../modules/system/hardware/audio.nix
    ../../modules/system/hardware/bluetooth.nix
    ../../modules/system/hardware/storage.nix
    ../../modules/system/hardware/snapshots.nix
    ../../modules/system/hardware/udev.nix
    ../../modules/system/hardware/power.nix

    # desktop: the graphical session
    ../../modules/system/desktop/niri.nix
    ../../modules/system/desktop/steam.nix
    ../../modules/system/desktop/xwayland.nix

    ../../modules/system/packages.nix
  ];

  # This value determines the NixOS release from which the default settings
  # for stateful data were taken. Leave it at the release of the first
  # install of this system — see configuration.nix(5).
  system.stateVersion = "26.05";
  
  boot.kernelPackages = inputs.kernel-nixpkgs.legacyPackages.${pkgs.system}.linuxPackages_latest;
}
