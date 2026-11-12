{ pkgs, dotfiles, ... }:

{
  programs.fish = {
    enable = true;
    # Distro-agnostic shell config lives in dotfiles/fish; only nix-specific
    # aliases/functions stay here (they go away with NixOS).
    shellAliases = {
      nix-rebuild = "sudo nixos-rebuild switch --flake ~/sys-cfg/nix";
      nix-update = "nix flake update --flake ~/sys-cfg/nix && sudo nixos-rebuild switch --flake ~/sys-cfg/nix";
    };
    plugins = [
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "bass";
        src = pkgs.fishPlugins.bass.src;
      }
    ];
    functions = {
      nix = ''
        if status is-interactive
          and set -q argv[1]
          and contains -- $argv[1] develop shell
          and not contains -- -c $argv
          and not contains -- --command $argv
          command nix $argv --command fish
          return
        end
        command nix $argv
      '';
    };
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  xdg.configFile."starship.toml".source = "${dotfiles}/starship.toml";

  # Only conf.d: dotfiles/fish/{arch,fish_plugins} are for the Arch setup.
  xdg.configFile."fish/conf.d" = {
    source = "${dotfiles}/fish/conf.d";
    recursive = true;
  };
}
