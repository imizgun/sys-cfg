{ pkgs, dotfiles, ... }:

{
  home.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  # Keeps HM's font-dir registration (10-hm-fonts.conf, nix-only); default
  # families and rendering live in dotfiles/fontconfig.
  fonts.fontconfig.enable = true;

  xdg.configFile."fontconfig/conf.d" = {
    source = "${dotfiles}/fontconfig/conf.d";
    recursive = true;
  };
}