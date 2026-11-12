{ ... }:

{
  # powerOnBoot defaults to true already — Bluetooth radio comes up on its
  # own at boot, no need to set it explicitly.
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        # Default is "never": if a paired device shows up with a link key
        # BlueZ no longer recognizes (e.g. it was reset or re-paired with
        # another host), BlueZ silently refuses the connection instead of
        # re-pairing. "always" lets it re-pair transparently — this is what
        # fixes a stale bond throwing org.bluez.Error.Failed
        # br-connection-key-missing.
        JustWorksRepairing = "always";
        FastConnectable = true;
        MultiProfile = "multiple";
        Experimental = true; # needed for battery % (BlueZ Battery Provider API)
      };
      Policy.AutoEnable = true;
    };
  };
}
