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

    # desktop apps 
    loupe
    inputs.sonora.packages.${pkgs.system}.default
  ];
}
