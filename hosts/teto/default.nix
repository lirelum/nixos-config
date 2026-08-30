{
  lib,
  pkgs,
  inputs,
  ...
}:
{

  _module.args.disks = [ "/dev/nvme0n1" ];

  networking.hostName = "teto";

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

  imports = [
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p14s-amd-gen6
  ]
  ++ lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix
  ++ lib.optional (builtins.pathExists ./vm-configuration.nix) ./vm-configuration.nix
  ++ [
    inputs.disko.nixosModules.disko
    ./disko-config.nix
  ];

  # Laptop power & services
  services.power-profiles-daemon.enable = true;
  services.fstrim.enable = true;
  services.fwupd.enable = true;
  services.fprintd.enable = true;

  hardware.graphics.extraPackages = with pkgs; [ rocmPackages.clr.icd ];

  services.xserver.videoDrivers = [ "amdgpu" ];

  boot.initrd.kernelModules = [ "amdgpu" ];

  system.stateVersion = "26.05";
}
