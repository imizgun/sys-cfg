{ pkgs, dotfiles, ... }:

{
  home.packages = [ pkgs.kitty ];

  # Nord theme is vendored in dotfiles/kitty/themes, no kitty-themes package.
  xdg.configFile."kitty" = {
    source = "${dotfiles}/kitty";
    recursive = true;
  };
}
