{ pkgs, lib, ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      terminal.shell.program = "${lib.getExe pkgs.zellij}";
    };
  };
}
