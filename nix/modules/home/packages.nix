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

    # dev tools
    bun
    claude-code
  ];
}
