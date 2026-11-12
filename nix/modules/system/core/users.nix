{ lib, pkgs, username, ... }:

{
  users.users.${username} = {
    isNormalUser = true;
    description = "Mikhail";
    extraGroups = [ "networkmanager" "wheel" "dialout" ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
  # NixOS' default ls/ll/l aliases land in /etc/fish/config.fish, which fish
  # reads after ~/.config/fish/conf.d — they'd override `alias ls nls` there.
  environment.shellAliases = lib.mkForce { };
}
