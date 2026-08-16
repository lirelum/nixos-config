{ lib, config, ... }: {
  options.my.audio.enable = lib.mkEnableOption "audio";
  config = lib.mkIf config.my.audio.enable {
    hardware.pulseaudio.enable = false;

    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    services.pipewire.wireplumber.enable = true;

  };
}
