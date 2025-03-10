# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, pkgs, lib, ... }:
let
  availableBrowsers = [
    { name = "firefox"; package = pkgs.firefox; desktopFile = "firefox.desktop"; }
    { name = "chromium"; package = pkgs.chromium; desktopFile = "chromium-browser.desktop"; }
  ];
in {
  options = {
    defaultPrograms.browser = lib.mkOption {
      type = lib.types.enum (map (b: b.name) availableBrowsers ++ ["none"]);
      default = "none";
      description = "Default browser to use";
    };
  };

  config = lib.mkIf (config.defaultPrograms.browser != "none") {
    home.sessionVariables = {
      BROWSER = config.defaultPrograms.browser;
      DEFAULT_BROWSER = config.defaultPrograms.browser;
    };
  };
}
