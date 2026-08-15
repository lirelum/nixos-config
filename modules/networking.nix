{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.my = {
    networking.enable = lib.mkEnableOption "networking";
    bluetooth.enable = lib.mkEnableOption "bluetooth";
  };
  config = lib.mkMerge [
    (lib.mkIf config.my.networking.enable {
      networking.networkmanager.enable = true;
      environment.systemPackages = with pkgs; [
        iproute2
        iw
      ];
    })
    (lib.mkIf config.my.bluetooth.enable {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
      };
    })
  ];
}
