{ ... }:

{
  # Source of truth is dotfiles/niri in this same repo (sys-cfg) — edit it
  # and rebuild to pick up changes. Symlinking the whole directory (not just
  # config.kdl) keeps the `include "./cfg/*.kdl"` relative paths inside
  # config.kdl working. A relative path inside the repo keeps evaluation pure,
  # so no --impure is needed.
  xdg.configFile."niri" = {
    source = ../../../../dotfiles/niri;
    recursive = true;
  };
}
