# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# User-specific theme customization
{ config, pkgs, lib, ... }: {
  stylix = {
    # Wallpaper - uncomment and modify as needed
    # image = pkgs.fetchurl {
    #   url = "https://raw.githubusercontent.com/dracula/wallpaper/master/base.png";
    #   sha256 = "..."; # Replace with actual hash
    # };
    
    # Color scheme - choose one
    base16Scheme = {
      # Dracula
      dracula = "${pkgs.base16-schemes}/share/themes/dracula.yaml";
      # Nord
      nord = "${pkgs.base16-schemes}/share/themes/nord.yaml";
      # Gruvbox
      gruvbox = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
      # Tokyo Night
      tokyoNight = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
      # Catppuccin
      catppuccin = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    }.dracula; # Change this to your preferred scheme

    # Font configuration
    fonts = {
      # Monospace options
      monospace = {
        # JetBrains Mono
        jetbrains = {
          package = pkgs.jetbrains-mono;
          name = "JetBrains Mono";
        };
        # Fira Code
        fira = {
          package = pkgs.fira-code;
          name = "Fira Code";
        };
        # Hack
        hack = {
          package = pkgs.hack-font;
          name = "Hack";
        };
      }.jetbrains; # Change this to your preferred font

      # Font sizes
      sizes = {
        terminal = 12;
        applications = 11;
        desktop = 11;
      };
    };

    # Opacity settings
    opacity = {
      terminal = 0.95;
      applications = 1.0;
      desktop = 1.0;
    };

    # Application targets
    targets = {
      alacritty.enable = true;
      vim.enable = true;
      gtk.enable = true;
      kde.enable = false;
      gnome.enable = true;
      xfce.enable = false;
      console.enable = true;
    };
  };
}
