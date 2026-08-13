{ pkgs, ... }:

{
  users.users."vkabaczko" = {
    isNormalUser = true;
    description = "Mikhail";
    extraGroups = [ "networkmanager" "wheel" "dialout" ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
}
