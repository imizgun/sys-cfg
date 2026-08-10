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
}
