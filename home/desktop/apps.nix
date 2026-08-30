{ pkgs, ... }: {
  home.packages = with pkgs; [
    anki
    nicotine-plus
    calibre
  ];
}
