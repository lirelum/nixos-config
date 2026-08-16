{ pkgs, ... }: {
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      jnoortheen.nix-ide
      mkhl.direnv
    ];
    userSettings = {
      "files.autoSave" = "onFocusChange";
      "chat.disableAIFeatures" = true;
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nixd";
      "nix.serverSettings"."nil"."formatting" = {
        "command" = [ "nixfmt" ];
      };
    };
  };
}
