{ dotfiles, ... }:

{
  hm.programs.helix.enable = true;

  hm.xdg.configFile."helix" = {
    source = "${dotfiles}/helix";
    recursive = true;
  };
}
