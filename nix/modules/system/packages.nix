{ pkgs, ... }:

{
  # CLI/system-wide tools only — user-facing apps belong in
  # modules/home/packages.nix instead.
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    pavucontrol
  ];
}
