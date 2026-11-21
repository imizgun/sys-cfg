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
}
