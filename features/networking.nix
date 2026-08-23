{ pkgs, ... }:
{
  networking.networkmanager.enable = true;
  environment.systemPackages = with pkgs; [
    iproute2
    iw
  ];
}
