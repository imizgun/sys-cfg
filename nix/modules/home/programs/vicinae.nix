{ dotfiles, ... }:

{
  # Declarative part of the vicinae config. ~/.config/vicinae/settings.json
  # stays a writable real file (the GUI rewrites it) and imports this one:
  #   { "imports": ["sys-cfg.json"] }
  # Extensions are installed from vicinae's store UI here; the decman side
  # installs them itself (decman/modules/programs/vicinae.py).
  xdg.configFile."vicinae/sys-cfg.json".source = "${dotfiles}/vicinae/sys-cfg.json";
}
