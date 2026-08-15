{
  lib,
  pkgs,
  inputs,
  ...
}:
{

  time.timeZone = "America/New_York";

  imports =
    lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix
    ++ lib.optional (builtins.pathExists ./vm-configuration.nix) ./vm-configuration.nix
    ++ [
      inputs.disko.nixosModules.disko
      ./disko-config.nix
    ];

  nixpkgs.hostPlatform.system = "x86_64-linux";

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ rocmPackages.clr.icd ];
  };

  #my.home.enable = true;
  my.users.autumn.enable = true;

  services.xserver.videoDrivers = [ "amdgpu" ];

  boot.initrd.kernelModules = [ "amdgpu" ];

  system.stateVersion = "26.05";
}
