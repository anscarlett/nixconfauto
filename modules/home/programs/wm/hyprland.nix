# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Hyprland configuration (Wayland)
{ config, pkgs, lib, ... }: {
  wayland.windowManager.hyprland = {
    enable = config.defaultPrograms.windowManager == "hyprland" || config.wayland.windowManager.hyprland.enable;
    extraConfig = ''
      # Monitor configuration
      monitor=,preferred,auto,1

      # Input configuration
      input {
        kb_layout = us
        follow_mouse = 1
        touchpad {
          natural_scroll = true
        }
      }

      # General settings
      general {
        gaps_in = 5
        gaps_out = 10
        border_size = 2
        col.active_border = rgba(33ccffee)
        col.inactive_border = rgba(595959aa)
      }

      # Basic keybinds
      bind = SUPER, Return, exec, alacritty
      bind = SUPER, Q, killactive
      bind = SUPER, Space, exec, rofi -show drun
      bind = SUPER SHIFT, E, exit
    '';
  };

  # Hyprland-specific packages
  home.packages = with pkgs; [
    waybar          # Wayland bar
    swaylock        # Screen locker
    swayidle        # Idle management
    wl-clipboard    # Clipboard manager
    grim            # Screenshot utility
    slurp           # Screen area selection
  ];
}
