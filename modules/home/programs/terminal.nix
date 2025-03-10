# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Terminal configuration
{ config, pkgs, lib, ... }: {
  programs.alacritty = {
    enable = config.defaultPrograms.terminal == "alacritty" || config.programs.alacritty.enable;
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
