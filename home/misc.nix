{ pkgs, ... }: {
  home.packages = with pkgs; [
    anki
    unstable.opencode
    nicotine-plus
  ];
}
