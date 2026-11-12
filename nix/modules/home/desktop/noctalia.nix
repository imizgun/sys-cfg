{ dotfiles, hostname, lib, ... }:

let
  hostFile = "${dotfiles}/noctalia/hosts/${hostname}.toml";
in
{
  # noctalia v5 merges every *.toml in ~/.config/noctalia, then applies the
  # GUI's overrides from ~/.local/state/noctalia/settings.toml on top. The
  # repo owns the first layer; persist GUI tweaks with `noctalia config export`.
  xdg.configFile = {
    "noctalia/config.toml".source = "${dotfiles}/noctalia/config.toml";
  } // lib.optionalAttrs (builtins.pathExists hostFile) {
    # monitor names / user paths differ per machine
    "noctalia/host.toml".source = hostFile;
  };
}
