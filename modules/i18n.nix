{ pkgs, ... }: {
  i18n.defaultLocale = "ja_JP.UTF-8";

  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "fr_CA.UTF-8/UTF-8"
    "ja_JP.UTF-8/UTF-8"
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];
}
