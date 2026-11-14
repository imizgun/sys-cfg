{ pkgs, ... }:

{
  services.upower.enable = true;

  hm.home.packages = [ pkgs.upower ]; # `upower -d` CLI
}
