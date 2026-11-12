{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting

      # espup (esp-rs Xtensa toolchain) generates this as a bash script;
      # bass lets fish source it so PATH/LIBCLANG_PATH stay in sync across
      # toolchain updates without hardcoding versioned paths here.
      if test -f $HOME/export-esp.sh
        bass source $HOME/export-esp.sh
      end
    '';
    shellAliases = {
      ls = "nls";
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
    settings = builtins.fromTOML (builtins.readFile ./starship.toml);
  };
}
