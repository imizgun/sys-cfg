{ pkgs, dotfiles, ... }:

{
  # Login shell (users.users.<name>.shell, core/users.nix) needs the system side.
  programs.fish.enable = true;

  hm.programs.fish = {
    enable = true;
    # Distro-agnostic shell config lives in dotfiles/fish; only nix-specific
    # aliases/functions stay here.
    shellAliases = {
      nix-rebuild = "nh os switch";            # build + diff + activate
      nix-upgrade = "nh os switch --update";   # flake update, then the same
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
      # `nix develop` / `nix shell` open fish instead of bash.
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

  hm.programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  hm.xdg.configFile."starship.toml".source = "${dotfiles}/starship.toml";

  # Plugins come from nixpkgs (above), so only conf.d is linked.
  hm.xdg.configFile."fish/conf.d" = {
    source = "${dotfiles}/fish/conf.d";
    recursive = true;
  };
}
