{ config, ... }:

{
  # Source of truth is the cloned dotfiles repo, not this flake — edit
  # ~/niri-dotfiles and rebuild to pick up changes. Symlinking the whole
  # directory (not just config.kdl) keeps the `include "./cfg/*.kdl"`
  # relative paths inside config.kdl working.
  xdg.configFile."niri" = {
    # Nix path value (not a string) so this still gets copied into the
    # store at eval time like the old hardcoded literal did — keeps the
    # existing --impure/"rebuild to pick up changes" behavior (see README).
    source = /. + config.home.homeDirectory + "/niri-dotfiles/niri";
    recursive = true;
  };
}
