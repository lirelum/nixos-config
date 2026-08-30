{ pkgs, outputs, ... }:
let
  username = "autumn";
in
{
  imports = [ ../home-manager.nix ];

  my.username = username;

  users.users.${username} = {
    isNormalUser = true;
    description = "Autumn";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
    ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;

  home-manager.users.${username} = {
    imports = with outputs.homeModules; [
      autumn
      cli
      desktop
    ];
  };
}
