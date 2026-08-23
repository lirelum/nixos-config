{ pkgs, ... }: {
  programs.vscode = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      jnoortheen.nix-ide
      mkhl.direnv
      ms-ceintl.vscode-language-pack-ja
    ];
    profiles.default.userSettings = {
      "editor.formatOnSave" = true;
      "editor.formatOnSaveMode" = "file";
      "files.autoSave" = "onFocusChange";
      "chat.disableAIFeatures" = true;
      "git.confirmSync" = false;
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nixd";
      "nix.formatterPath" = "nixfmt";
      "nix.serverSettings"."nil"."formatting" = {
        "command" = [ "nixfmt" ];
      };
    };
  };
}
