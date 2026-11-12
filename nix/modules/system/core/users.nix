{ pkgs, username, ... }:

{
  users.users.${username} = {
    isNormalUser = true;
    description = "Mikhail";
    extraGroups = [ "networkmanager" "wheel" "dialout" ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
}
