{
  lib,
  pkgs,
  inputs,
  ...
}:
{

  _module.args.disks = [ "/dev/nvme0n1" ];

  networking.hostName = "miku";

  boot.loader = {
    systemd-boot.enable = true;
    efi.efiSysMountPoint = "/efi";
    efi.canTouchEfiVariables = true;
  };

  time.timeZone = "America/New_York";

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  console.useXkbConfig = true;

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

  services.xserver.videoDrivers = [ "amdgpu" ];

  boot.initrd.kernelModules = [ "amdgpu" ];

  system.stateVersion = "26.05";
}
