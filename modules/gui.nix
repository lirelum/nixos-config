{ lib, config, ... }: {
  options.my.gui.enable = lib.mkEnableOption "gui config";
  config = lib.mkIf config.my.gui.enable {
    services.xserver = {
      enable = true;
    };
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
