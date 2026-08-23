{ pkgs, ... }: {
  home.packages = with pkgs; [
    anki
    claude-code
    nicotine-plus
  ];
}
