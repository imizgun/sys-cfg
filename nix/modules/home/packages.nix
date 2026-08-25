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
    rustfmt
    gcc
    cmake
    python3
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

    # desktop apps
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
    t3code
  ] ++ lib.optionals (hostname == "laptop") [
    # photo editing, laptop only
    rawtherapee
    darktable
  ];
}
