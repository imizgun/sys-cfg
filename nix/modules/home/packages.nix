{ pkgs, lib, inputs, hostname, ... }:

let
  # 0.8.2 has a bug affecting us; pin back to 0.8.1 until it's fixed upstream.
  xwayland-satellite-0-8-1 =
    let
      pinnedSrc = pkgs.fetchFromGitHub {
        owner = "Supreeeme";
        repo = "xwayland-satellite";
        tag = "v0.8.1";
        hash = "sha256-BUE41HjLIGPjq3U8VXPjf8asH8GaMI7FYdgrIHKFMXA=";
      };
    in
    pkgs.xwayland-satellite.overrideAttrs (old: {
      version = "0.8.1";
      src = pinnedSrc;
      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        inherit (old) pname;
        version = "0.8.1";
        src = pinnedSrc;
        hash = "sha256-16L6gsvze+m7XCJlOA1lsPNELE3D364ef2FTdkh0rVY=";
      };
    });
in
{
  home.packages = with pkgs; [
    # browsers
    firefox
    inputs.zen-browser.packages.${pkgs.system}.default
    google-chrome

    # editors
    zed-editor

    # IDEs
    jetbrains.rust-rover
    jetbrains.rider

    # chat
    telegram-desktop

    # desktop shell for niri
    noctalia
    xwayland-satellite-0-8-1

    # terminal (bound to Mod+T in the niri dotfiles)
    ghostty
    kitty-themes

    # dev tools
    bun
    claude-code
    nil
    inputs.nls.packages.${pkgs.system}.default
    nixd
    yazi
    rustup
    gcc
    espup
    espflash
    cmake
    python3
    flow-control
    dotnet-sdk_11
    dotnet-ef
    gh
    clang-tools
    btop
    jq
    slurp
    grim
    man
    bat
    amdgpu_top
    upower
    yt-dlp
    ffmpeg

    # desktop apps
    vicinae
    loupe
    nautilus
    inputs.ricture.packages.${pkgs.system}.default
    inputs.sonora.packages.${pkgs.system}.sonora-bin
    obs-studio
    mpv
    discord
    easyeffects
    onlyoffice-desktopeditors
    obsidian
    amnezia-vpn
  ] 
  ++ lib.optionals (hostname == "laptop") [
    # photo editing, laptop only
    rawtherapee
    darktable
  ]
  ++ lib.optionals (hostname == "nixos") [
  # games, PC only
    deadlock-mod-manager
    bluez
  ];
}
