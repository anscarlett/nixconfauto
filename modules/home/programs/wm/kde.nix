# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# KDE Plasma configuration
{ config, pkgs, lib, ... }: {
  # KDE Plasma configuration
  programs.plasma = {
    enable = config.defaultPrograms.windowManager == "kde" || config.programs.plasma.enable;
    
    # Workspace behavior
    shortcuts = {
      "kwin"."Switch to Desktop 1" = "Meta+1";
      "kwin"."Switch to Desktop 2" = "Meta+2";
      "kwin"."Switch to Desktop 3" = "Meta+3";
      "kwin"."Switch to Desktop 4" = "Meta+4";
      "kwin"."Window to Desktop 1" = "Meta+Shift+1";
      "kwin"."Window to Desktop 2" = "Meta+Shift+2";
      "kwin"."Window to Desktop 3" = "Meta+Shift+3";
      "kwin"."Window to Desktop 4" = "Meta+Shift+4";
    };
  };

  # KDE-specific packages
  home.packages = with pkgs; [
    libsForQt5.bismuth    # Tiling extension
    libsForQt5.yakuake    # Drop-down terminal
    libsForQt5.kcalc      # Calculator
    libsForQt5.kdeconnect-kde # Phone integration
    libsForQt5.krdc       # Remote desktop client
  ];
}
