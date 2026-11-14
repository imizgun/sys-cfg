{ pkgs, lib, inputs, hostname, ... }:

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
    jetbrains.idea

    # chat
    telegram-desktop

    # desktop shell for niri
    noctalia
    xwayland-satellite

    # dev tools
    bun
    gnumake
    claude-code
    nil
    inputs.nls.packages.${pkgs.system}.default
    inputs.wayzoomy.packages.${pkgs.system}.default
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
    nodejs
    fzf
    nasm
    xmake
    virtiofsd

    # desktop apps
    vicinae
    loupe
    nautilus
    inputs.ricture.packages.${pkgs.system}.default
    inputs.sonora.packages.${pkgs.system}.default
    obs-studio
    mpv
    photocraft
    wordcraft
    
    # from nixpkgs master, see the nixpkgs-master input in flake.nix
    (import inputs.nixpkgs-master {
      inherit (pkgs) system;
      config.allowUnfree = true;
    }).discord
    easyeffects
    onlyoffice-desktopeditors
    obsidian
  ]
  ++ lib.optionals (hostname == "laptop") [
    # photo editing, laptop only
    rawtherapee
    darktable
  ]
  ++ lib.optionals (hostname == "nixos") [
  # games, PC only
    (pkgs.callPackage ../../pkgs/deadlock-mod-manager.nix { })
    bluez
    supertuxkart
  ];
}
