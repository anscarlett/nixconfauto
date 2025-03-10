# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Chromium configuration
{ config, pkgs, lib, ... }: {
  programs.chromium = {
    enable = config.defaultPrograms.browser == "chromium" || config.programs.chromium.enable;
    commandLineArgs = [
      "--force-dark-mode"            # Enable dark mode
      "--lang=en-GB"                 # Set language to British English
      "--disk-cache-size=104857600"  # 100MB cache size
    ];
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # Privacy Badger
      "gcbommkclmclpchllfjekcdonpmejbdp" # HTTPS Everywhere
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
      "pebeiooifmkjgnpgcnmfhfkoicpghpeo" # Keepa - Amazon Price Tracker
      "gebbhagfogifgggkldgodflihgfeippi" # Return YouTube Dislike
    ];
  };
}
