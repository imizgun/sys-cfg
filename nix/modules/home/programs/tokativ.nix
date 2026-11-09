{ inputs, ... }:

{
  imports = [ inputs.tokativ.homeModules.default ];

  services.tokativ = {
    enable = true;
  };
}
