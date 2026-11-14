{ ... }:

{
  # `use flake` in .envrc, cached by nix-direnv.
  hm.programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableFishIntegration = true;
  };
}
