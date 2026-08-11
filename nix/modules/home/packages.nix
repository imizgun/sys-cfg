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

    # desktop apps
    loupe
    nautilus
    inputs.sonora.packages.${pkgs.system}.default
    obs-studio
    mpv
  ];
}
