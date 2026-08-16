{
  lib,
  config,
  pkgs,
  outputs,
  ...
}:
{
  options = {
    my.users.autumn.enable = lib.mkEnableOption "user autumn";
  };
  config = lib.mkMerge [
    (lib.mkIf config.my.users.autumn.enable {
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

      home-manager = lib.mkIf config.my.home.enable {
        users.autumn = {
          imports = builtins.attrValues outputs.homeModules;
          programs.zsh.enable = true;
        };
      };
    })
  ];
}
