{ dotfiles, ... }:

{
  programs.helix.enable = true;

  xdg.configFile."helix" = {
    source = "${dotfiles}/helix";
    recursive = true;
  };
}
