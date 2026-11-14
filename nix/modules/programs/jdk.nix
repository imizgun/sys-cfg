{ pkgs, ... }:

{
  hm.programs.java = {
    enable = true;
    package = pkgs.jdk25;
  };

  hm.home.packages = [ pkgs.maven ];
}
