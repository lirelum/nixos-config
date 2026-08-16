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
      adwaita-qt
      adwaita-qt6
    ];
    qt = {
      enable = true;
      platformTheme = "qt5ct";
    };
    environment.sessionVariables.XDG_DATA_DIRS = [
      "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
      "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
    ];
  };
}
