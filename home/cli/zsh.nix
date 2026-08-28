{ pkgs, lib, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ls = "${lib.getExe pkgs.eza}";
      la = "${lib.getExe pkgs.eza} -a";
      ll = "${lib.getExe pkgs.eza} -la";
      lt = "${lib.getExe pkgs.eza} --tree";
      nsw = "sudo ${lib.getExe pkgs.nixos-rebuild} switch --flake ~/.config/nixos/";
    };
  };
}
