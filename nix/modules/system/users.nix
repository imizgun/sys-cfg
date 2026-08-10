{ pkgs, ... }:

{
  users.users."vkabaczko" = {
    isNormalUser = true;
    description = "Mikhail";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
}
