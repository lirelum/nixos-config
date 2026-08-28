{ pkgs, outputs, ... }: {
  imports = [ ../home-manager.nix ];

  users.users.autumn = {
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

  home-manager.users.autumn = {
    imports = with outputs.homeModules; [
      autumn
      cli
      desktop
    ];
  };
}
