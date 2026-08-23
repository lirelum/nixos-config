{ pkgs, outputs, ... }:
{
  imports = [ ../home.nix ];

  users.users.autumn = {
    isNormalUser = true;

    initialPassword = "changeme";

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

  home-manager.users.autumn = {
    imports = builtins.attrValues outputs.homeModules;
    programs.zsh.enable = true;
  };
}
