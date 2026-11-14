{ pkgs, dotfiles, ... }:

{
  hm.home.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    liberation_ttf
    jetbrains-mono # prebuilt, see overlays/fixes.nix
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  # Keeps HM's font-dir registration (10-hm-fonts.conf, nix-only); default
  # families and rendering live in dotfiles/fontconfig.
  hm.fonts.fontconfig.enable = true;

  hm.xdg.configFile."fontconfig/conf.d" = {
    source = "${dotfiles}/fontconfig/conf.d";
    recursive = true;
  };
}
