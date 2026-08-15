{lib, config, pkgs, outputs, ...}: {
  options = {
    my.users.autumn.enable = lib.mkEnableOption "user autumn";
  };
  config = {
    users.users.autumn = lib.mkIf config.my.users.autumn.enable {
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
    programs.zsh.enable = lib.mkIf config.my.users.autumn.enable true;
    
    home-manager = lib.mkIf config.my.home.enable {
      users.autumn = lib.mkIf config.my.users.autumn.enable {
        imports = builtins.attrValues outputs.homeModules;

        programs.zsh.enable = true;
      };
    };
  };
}