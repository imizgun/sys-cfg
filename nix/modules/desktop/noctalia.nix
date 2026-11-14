{ pkgs, lib, dotfiles, hostname, ... }:

let
  # The PC is `nixos` here but `mainpc` in dotfiles/.
  name = if hostname == "nixos" then "mainpc" else hostname;
  hostFile = "${dotfiles}/noctalia/hosts/${name}.toml";
in
{
  # desktop shell for niri
  hm.home.packages = [ pkgs.noctalia ];

  # noctalia v5 merges every *.toml in ~/.config/noctalia, then applies the
  # GUI's overrides from ~/.local/state/noctalia/settings.toml on top. The
  # repo owns the first layer; persist GUI tweaks with `noctalia config export`.
  hm.xdg.configFile = {
    "noctalia/config.toml".source = "${dotfiles}/noctalia/config.toml";
  } // lib.optionalAttrs (builtins.pathExists hostFile) {
    # monitor names / user paths differ per machine
    "noctalia/host.toml".source = hostFile;
  };
}
