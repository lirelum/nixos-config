{ inputs, pkgs, ... }: {
  programs.firefox = {
    enable = true;
    package = pkgs.unstable.firefox;
    languagePacks = [
      "ja"
      "en"
      "fr"
    ];
    profiles.default = {
      id = 0;
      name = "Default";
      isDefault = true;
      settings = {
        "intl.locale.requested" = "ja";
        "intl.accept_languages" = "ja-JP, ja, fr-CA, fr, en-US, en";
        "sidebar.revamp" = true;
        "sidebar.verticalTabs" = true;
        "sidebar.visibility" = "always-show";
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      };
      extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
        ublock-origin
        bitwarden
        yomitan
      ];
    };
  };
}
