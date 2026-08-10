{ pkgs, ... }:

{
  programs.niri.enable = true;

  services.greetd.enable = true;
  services.greetd.settings.default_session.command =
    "${pkgs.tuigreet}/bin/tuigreet --remember --cmd niri-session";

  # CLI/system-wide tools only — user-facing apps belong in
  # modules/home/packages.nix instead.
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];
}
