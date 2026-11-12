{pkgs, ...}:

{
  services.udev.packages = [ pkgs.via ];
  hardware.keyboard.qmk.enable = true;
}