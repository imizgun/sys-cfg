{ pkgs, username, ... }:

{
  # KVM/QEMU via libvirt, managed from virt-manager.
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = false;
      # software TPM — needed for Windows 11 guests. OVMF (UEFI) firmware
      # ships with QEMU by default, no extra option required.
      swtpm.enable = true;
      # virtiofs shared folders (virt-manager: Add Hardware → Filesystem)
      vhostUserPackages = [ pkgs.virtiofsd ];
    };
  };

  # USB passthrough to guests over SPICE without root.
  virtualisation.spiceUSBRedirection.enable = true;

  # Installs virt-manager and its dconf schemas system-wide.
  programs.virt-manager.enable = true;

  users.users.${username}.extraGroups = [ "libvirtd" "kvm" ];

  # virtiofsd on PATH too, for running it by hand
  hm.home.packages = [ pkgs.virtiofsd ];
}
