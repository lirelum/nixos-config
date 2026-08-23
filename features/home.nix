{ inputs, outputs, ... }:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "bkp";
  home-manager.extraSpecialArgs = { inherit inputs outputs; };
  home-manager.sharedModules = builtins.attrValues outputs.homeModules;
}
