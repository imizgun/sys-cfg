{ pkgs, ... }:

{
  services.snapper = {
    # every 2 days (day-of-month step syntax; imprecise by ~1 day at
    # month boundaries, systemd.time(7) has no plain "every N days")
    snapshotInterval = "*-*-1/2 00:00:00";
    # catch up a missed snapshot (e.g. laptop was off) instead of skipping it
    persistentTimer = true;

    configs.home = {
      SUBVOLUME = "/home";
      ALLOW_USERS = [ "vkabaczko" ];
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_HOURLY = 0;
      TIMELINE_LIMIT_DAILY = 7;
      TIMELINE_LIMIT_WEEKLY = 4;
      TIMELINE_LIMIT_MONTHLY = 6;
      TIMELINE_LIMIT_YEARLY = 0;
    };
  };

  # snapper requires a pre-existing ".snapshots" subvolume inside every
  # SUBVOLUME it manages and won't create one itself (snapper-configs(5)).
  system.activationScripts.snapperHomeSubvolume = ''
    if [ ! -d /home/.snapshots ]; then
      ${pkgs.btrfs-progs}/bin/btrfs subvolume create /home/.snapshots
      chmod 750 /home/.snapshots
    fi
  '';
}
