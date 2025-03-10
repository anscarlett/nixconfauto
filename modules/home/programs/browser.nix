# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Browser configuration
{ config, pkgs, lib, ... }: {
  imports = [
    # Browsers
    ./browser/firefox.nix    # Firefox configuration
    ./browser/chromium.nix   # Chromium configuration
  ];

  # Common browser dependencies and tools
  home.packages = with pkgs; [
    # Desktop integration
    xdg-utils              # For browser integration with desktop
    xdg-user-dirs         # For managing user directories
    
    # Media plugins
    gst_all_1.gst-plugins-base    # Basic media support
    gst_all_1.gst-plugins-good    # Additional codecs
    gst_all_1.gst-libav           # FFmpeg support
    
    # PDF viewing
    evince                 # GNOME PDF viewer
    zathura                # Minimal PDF viewer
    
    # Download management
    aria2                  # Download manager
    youtube-dl            # Media downloader
    
    # Password management
    bitwarden             # Password manager
    bitwarden-cli         # CLI interface
  ];
}
