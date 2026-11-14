{ pkgs, dotfiles, ... }:

{
  hm.home.packages = [ pkgs.vicinae ];

  # Declarative part of the vicinae config. ~/.config/vicinae/settings.json
  # stays a writable real file (the GUI rewrites it) and imports this one:
  #   { "imports": ["sys-cfg.json"] }
  # Extensions are installed from vicinae's store UI.
  hm.xdg.configFile."vicinae/sys-cfg.json".source = "${dotfiles}/vicinae/sys-cfg.json";
}
