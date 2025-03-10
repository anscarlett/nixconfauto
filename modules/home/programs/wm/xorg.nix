# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Xorg fallback configuration
{ config, pkgs, lib, ... }: {
  # Basic X session configuration
  xsession = {
    enable = config.defaultPrograms.windowManager == "xorg" || config.xsession.enable;
    
    # Basic window manager fallback (TWM)
    windowManager.command = lib.mkDefault "twm";
    
    # Basic X initialization
    initExtra = ''
      # Set background color
      xsetroot -solid '#222222'
      
      # Basic key repeat rate
      xset r rate 200 30
      
      # Basic screen saver settings
      xset s 300 300
      xset dpms 300 300 300
    '';
  };

  # Basic X utilities
  home.packages = with pkgs; [
    xorg.twm          # Basic window manager
    xorg.xclock       # Basic clock
    xorg.xterm        # Basic terminal
    xorg.xsetroot     # Root window utility
    xorg.xev          # Event viewer
    xorg.xmodmap      # Keyboard modifier
    xorg.xrandr       # Display configuration
    xorg.xrdb         # Resource database utility
  ];
}
