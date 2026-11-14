{ pkgs, ... }:

# Laptop only (hosts/laptop).
{
  hm.home.packages = with pkgs; [
    rawtherapee
    darktable
  ];
}
