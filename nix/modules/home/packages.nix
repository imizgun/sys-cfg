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

    # terminal (bound to Mod+T in the niri dotfiles)
    ghostty
    kitty-themes

    # dev tools
    bun
    claude-code
    nil
    nls
    yazi
  ];
}
