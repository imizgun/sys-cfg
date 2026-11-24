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

  # LTS, not linuxPackages_latest: on 7.3.x the O2 Micro SD reader inits
  # cards but every block read fails (I/O error on sector 0); 6.18 LTS works.
  boot.kernelPackages = pkgs.linuxPackages;

  # TEMP: testing whether LTS still needs this. If "error -84" comes back,
  # restore it.
  # O2 Micro SD reader [1217:8621] fails card init with "error -84"
  # when switching to 1.8V UHS signalling. 0x4 = SDHCI_QUIRK2_NO_1_8_V
  # (cards fall back to High Speed, ~25 MB/s).
  # boot.kernelParams = [ "sdhci.debug_quirks2=0x4" ];
}
