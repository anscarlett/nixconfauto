# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# System-wide theme configuration
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

    # System-wide font configuration
    fonts = {
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };

      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };

      monospace = {
        package = pkgs.jetbrains-mono;
        name = "JetBrains Mono";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };

    # Target specific system components
    targets = {
      console.enable = true;
      plymouth.enable = true;
      grub.enable = true;
      gtk.enable = true;
      kde.enable = false;
      gnome.enable = true;
      xfce.enable = false;
    };
  };

  # Additional fonts
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
    ];

    # Font configuration
    fontconfig = {
      defaultFonts = {
        serif = [ "DejaVu Serif" ];
        sansSerif = [ "DejaVu Sans" ];
        monospace = [ "JetBrains Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
