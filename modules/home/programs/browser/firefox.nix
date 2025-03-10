# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Firefox configuration
{ config, pkgs, lib, ... }: {
  programs.firefox = {
    enable = config.defaultPrograms.browser == "firefox" || config.programs.firefox.enable;
    profiles.default = {
      settings = {
        "browser.startup.homepage" = "https://nixos.org";
        "browser.search.region" = "GB";
        "browser.search.isUS" = false;
        "intl.accept_languages" = "en-GB, en";
        "browser.search.countryCode" = "GB";
        "browser.urlbar.suggest.searches" = true;
        "browser.download.useDownloadDir" = false;
        "browser.bookmarks.showMobileBookmarks" = true;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "privacy.donottrackheader.enabled" = true;
        "dom.security.https_only_mode" = true;
        "general.useragent.locale" = "en-GB";
        "spellchecker.dictionary" = "en-GB";
        # UK date/time format
        "intl.date_time.pattern_override.date_short" = "dd/MM/yyyy";
        "intl.date_time.pattern_override.time_short" = "HH:mm";
        "intl.regional_prefs.use_os_locales" = true;
      };
      extensions = with pkgs.firefox-addons; [
        ublock-origin            # Ad blocker
        privacy-badger          # Privacy protection
        https-everywhere        # Force HTTPS
        darkreader              # Dark mode
        # UK-specific
        keepa                   # Amazon price tracker (supports amazon.co.uk)
        return-youtube-dislikes # Restore dislikes count
      ];
    };
  };
}
