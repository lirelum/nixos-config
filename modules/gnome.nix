{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.my.gnome.enable = lib.mkEnableOption "gnome desktop and gdm";
  config = lib.mkIf config.my.gnome.enable {
    my.gui.enable = true;
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
    environment.systemPackages = with pkgs; [
      gnome-tweaks
      gnomeExtensions.fullscreen-avoider
      gnomeExtensions.appindicator
    ];
  };
}
