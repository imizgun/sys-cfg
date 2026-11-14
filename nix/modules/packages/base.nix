{ pkgs, ... }:

{
  # System-wide CLI basics (also there for root and in a rescue shell).
  # Everything user-facing goes to hm.home.packages in the other files.
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    pavucontrol
  ];
}
