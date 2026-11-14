{ pkgs, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  hm.home.packages = [
    pkgs.firefox
    pkgs.google-chrome
    inputs.zen-browser.packages.${system}.default # from its flake (flake.nix)
  ];
}
