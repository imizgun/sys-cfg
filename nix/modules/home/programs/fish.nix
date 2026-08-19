{ pkgs, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = "set fish_greeting";
    shellAliases = {
      ls = "nls";
      nix-rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config --impure";
      nix-update = "nix flake update --flake ~/nixos-config && sudo nixos-rebuild switch --flake ~/nixos-config --impure";
    };
    plugins = [
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
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
    settings = {
      add_newline = false;

      format = "$directory$git_branch$git_status $character";
      right_format = "$cmd_duration";

      username.disabled = true;
      hostname.disabled = true;

      directory = {
        style = "cyan bold";
        truncation_length = 3;
        truncate_to_repo = true;
        format = "[$path]($style)";
      };

      git_branch = {
        symbol = " ";
        style = "yellow";
        format = "[ $symbol$branch]($style)";
      };

      git_status = {
        style = "red";
        format = "([ $all_status$ahead_behind]($style))";
        conflicted = "=";
        ahead = "⇡";
        behind = "⇣";
        diverged = "⇕";
        untracked = "";
        stashed = "";
        modified = "";
        staged = "[](green)";
        renamed = "»";
        deleted = "✘";
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };

      cmd_duration = {
        min_time = 1000;
        format = "[ $duration]($style)";
        style = "bright-black";
      };
    };
  };
}
