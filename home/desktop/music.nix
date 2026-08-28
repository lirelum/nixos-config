{ pkgs, ... }: {
  home.packages = with pkgs; [
    strawberry
    beets
    rsgain
    picard
  ];
}
