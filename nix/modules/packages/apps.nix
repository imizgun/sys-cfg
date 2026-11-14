{ pkgs, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  hm.home.packages = with pkgs; [
    # chat
    telegram-desktop
    discord

    # media
    loupe
    mpv
    obs-studio
    easyeffects

    # office / notes
    onlyoffice-desktopeditors
    obsidian
    photocraft
    wordcraft

    # from their own flakes (flake.nix inputs)
    inputs.sonora.packages.${system}.default
    inputs.ricture.packages.${system}.default
    inputs.wayzoomy.packages.${system}.default
  ];
}
