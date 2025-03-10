# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# i3 window manager configuration
{ config, pkgs, lib, ... }: {
  xsession.windowManager.i3 = {
    enable = config.defaultPrograms.windowManager == "i3" || config.xsession.windowManager.i3.enable;
    config = {
      modifier = "Mod4"; # Windows/Super key
      terminal = "alacritty";
      menu = "rofi -show drun";
      
      # Default workspaces
      workspaceOutputAssign = [
        { workspace = "1"; output = "primary"; }
        { workspace = "2"; output = "primary"; }
        { workspace = "3"; output = "primary"; }
      ];
      
      # Key bindings
      keybindings = lib.mkOptionDefault {
        "Mod4+Return" = "exec alacritty";
        "Mod4+d" = "exec rofi -show drun";
        "Mod4+Shift+q" = "kill";
        "Mod4+Shift+e" = "exec i3-nagbar -t warning -m 'Exit i3?' -B 'Yes' 'i3-msg exit'";
      };
    };
  };

  # i3-specific packages
  home.packages = with pkgs; [
    i3status
    i3blocks
    i3lock
  ];
}
