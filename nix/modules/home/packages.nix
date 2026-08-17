{ pkgs, inputs, ... }:

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
    xwayland-satellite

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
    cargo
    rust-analyzer
    rustc
    gcc
    cmake
    python3
    dotnet-sdk_11
    dotnet-ef
    gh
    clang-tools
    btop
    inputs.ricture.packages.${pkgs.system}.default

    # desktop apps
    loupe
    nautilus
    inputs.sonora.packages.${pkgs.system}.sonora-bin
    obs-studio
    mpv
    discord
    easyeffects
  ];
}
