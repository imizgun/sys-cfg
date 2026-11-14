{ pkgs, lib, ... }:

{
  # Steam with Millennium (pkgs.millennium-steam from the millennium overlay).
  programs.steam = lib.mkIf pkgs.stdenv.hostPlatform.isx86_64 {
    enable = true;

    package = pkgs.millennium-steam.override {
      extraPkgs = _: [
        pkgs.kdePackages.breeze
      ];
    };
  };

  # GDK_SCALE=2 is set globally in the niri config for the laptop's HiDPI
  # panel (eDP-1, scale 1.75 rounded up — GDK_SCALE only takes integers).
  # Steam honors it too, so on the external 1x monitor it renders 2x too
  # big. Override it back to 1 just for Steam rather than touching the
  # session-wide setting the laptop screen depends on.
  hm.xdg.desktopEntries.steam = {
    name = "Steam";
    genericName = "Application for managing and playing games on Steam";
    exec = "env GDK_SCALE=1 steam -forcedesktopscale 1 %U";
    icon = "steam";
    terminal = false;
    categories = [ "Network" "FileTransfer" "Game" ];
    mimeType = [ "x-scheme-handler/steam" "x-scheme-handler/steamlink" ];
  };
}
