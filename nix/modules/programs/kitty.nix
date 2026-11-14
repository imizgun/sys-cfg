{ pkgs, dotfiles, ... }:

{
  hm.home.packages = [ pkgs.kitty ];

  # Nord theme is vendored in dotfiles/kitty/themes, no kitty-themes package.
  hm.xdg.configFile."kitty" = {
    source = "${dotfiles}/kitty";
    recursive = true;
  };
}
