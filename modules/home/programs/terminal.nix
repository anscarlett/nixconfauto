# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Terminal configuration (using Alacritty)
{ config, pkgs, lib, ... }: {
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";

      window = {
        padding = {
          x = 10;
          y = 10;
        };
        decorations = "none";
        opacity = config.stylix.opacity.terminal;
      };

      # Font configuration is handled by stylix
    };
  };
}
