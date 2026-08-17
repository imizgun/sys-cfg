{ ... }:

{
  # Lets Nautilus (and any other GTK/GVfs-aware app) see, mount, and
  # automount removable media (USB flash drives, etc). Without this the
  # kernel still detects the block device (visible in `lsblk`), but
  # nothing offers to mount it — no udisks2, no GVfs, no polkit auth
  # agent, none of which niri brings in on its own the way a full DE
  # (GNOME/KDE) would.
  #
  # gvfs.enable pulls in udisks2.enable, which itself pulls in
  # security.polkit.enable — no need to set either by hand.
  services.gvfs.enable = true;

  fileSystems."/mnt/sda1" = {
    device = "/dev/disk/by-uuid/92033fe1-2e9a-432b-b6e7-4369740c2196";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };
}
