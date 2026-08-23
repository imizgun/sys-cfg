{ config, lib, ... }:

{
  # Unlike niri.nix, this can't be a read-only xdg.configFile symlink into
  # the Nix store: Noctalia's settings UI writes live changes (theme,
  # colors, bar/plugin layout) straight back into settings.json/colors.json
  # etc. A store-backed symlink would make those saves fail. Instead,
  # symlink ~/.config/noctalia directly to the dotfiles repo (writable,
  # git-tracked) — same as niri-dotfiles/install.sh does by hand, just run
  # automatically on every home-manager activation so both hosts stay in
  # sync without a manual install.sh step.
  home.activation.linkNoctaliaConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    target="${config.home.homeDirectory}/.config/noctalia"
    source="${config.home.homeDirectory}/niri-dotfiles/noctalia"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
      $DRY_RUN_CMD mv "$target" "$target.bak.$(date +%Y%m%d_%H%M%S)"
    fi

    if [ "$(readlink "$target")" != "$source" ]; then
      $DRY_RUN_CMD ln -sfn "$source" "$target"
    fi
  '';
}
