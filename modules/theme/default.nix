# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# System-wide theme configuration using stylix
{ config, pkgs, lib, inputs, ... }: {
  stylix = {
    image = pkgs.fetchurl {
      url = "https://raw.githubusercontent.com/dracula/wallpaper/master/base.png";
      sha256 = "..."; # Replace with actual hash
    };
    
    base16Scheme = "${pkgs.base16-schemes}/share/themes/dracula.yaml";

    # Font configuration
    fonts = {
      monospace = {
        package = pkgs.jetbrains-mono;
        name = "JetBrains Mono";
      };

      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };

      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };

      sizes = {
        terminal = 12;
        applications = 11;
        desktop = 11;
      };
    };

    # Cursor configuration
    cursor = {
      package = pkgs.dracula-theme;
      name = "Dracula-cursors";
      size = 24;
    };

    # Opacity settings
    opacity = {
      terminal = 0.95;
      applications = 1.0;
      desktop = 1.0;
    };

    # Target specific applications
    targets = {
      alacritty.enable = true;
      vim.enable = true;
      gtk.enable = true;
      kde.enable = false; # Enable if using KDE
      gnome.enable = true;
      xfce.enable = false; # Enable if using XFCE
      console.enable = true;
    };
  };

  # Additional theme-related configuration
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    inherit (config.stylix.cursor) package name size;
  };
}
