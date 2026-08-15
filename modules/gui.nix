{lib, config, ...}: {
  options.my.gui.enable = lib.mkEnableOption "gui config";
  config = lib.mkIf config.my.gui.enable {
    services.xserver = {
      enable = true;
    };
  };
}