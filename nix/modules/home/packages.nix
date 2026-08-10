{ pkgs, inputs, ... }:

{
  home.packages = with pkgs; [
    # browsers
    firefox
    inputs.zen-browser.packages.${pkgs.system}.default

    # editors
    zed-editor

    # chat
    telegram-desktop

    # desktop shell for niri
    noctalia

    # terminal (bound to Mod+T in the niri dotfiles)
    ghostty

    # dev tools
    bun
    claude-code
  ];
}
