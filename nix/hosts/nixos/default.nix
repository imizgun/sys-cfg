{ ... }:

# The PC (`mainpc` in dotfiles/). Common modules + PC-only ones.
{
  imports = [
    ./hardware-configuration.nix
    ../../modules
    ../../modules/packages/games.nix
  ];

  # This value determines the NixOS release from which the default settings
  # for stateful data were taken. Leave it at the release of the first
  # install of this system — see configuration.nix(5).
  system.stateVersion = "26.05";

  # Default nixpkgs kernel (LTS). 6.12 was pinned here before, but its
  # BlueZ 5.87 combo fails with getsockopt(L2CAP_OPTIONS) EOPNOTSUPP and
  # never registers the adapter.

  # Second disk — the PC only. nofail: a missing disk doesn't block boot.
  fileSystems."/mnt/sda1" = {
    device = "/dev/disk/by-uuid/92033fe1-2e9a-432b-b6e7-4369740c2196";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };
}
