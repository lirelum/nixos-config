{
  lib,
  inputs,
  config,
  outputs,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  options.my.home.enable = lib.mkEnableOption "home-manager config";
  config = lib.mkIf config.my.home.enable {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "bkp";
    home-manager.sharedModules = builtins.attrValues outputs.homeModules;
  };
}
