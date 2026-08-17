{ lib, config, ... }: {
  options.my.gaming.enable = lib.mkEnableOption "gaming";
  config = lib.mkIf config.my.gaming.enable {
    my.gui.enable = true;
    programs.steam = {
      enable = true;
    };

    programs.gamemode.enable = true;

    programs.gamescope.enable = true;
  };
}
