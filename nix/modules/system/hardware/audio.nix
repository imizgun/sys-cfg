{ ... }:

{
  # Required for PipeWire's realtime scheduling (no clicks/underruns).
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # audio.enable and wireplumber (session manager) both auto-derive to
    # true from the above — no need to set them explicitly.
  };
}
