{ pkgs, ... }: {
  home.packages = with pkgs.unstable; [
    mathematica
  ];
}
