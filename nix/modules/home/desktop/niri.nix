{ ... }:

{
  # Source of truth is the cloned dotfiles repo, not this flake — edit
  # ~/niri-dotfiles and rebuild to pick up changes. Symlinking the whole
  # directory (not just config.kdl) keeps the `include "./cfg/*.kdl"`
  # relative paths inside config.kdl working.
  xdg.configFile."niri" = {
    source = /home/vkabaczko/niri-dotfiles/niri;
    recursive = true;
  };
}
