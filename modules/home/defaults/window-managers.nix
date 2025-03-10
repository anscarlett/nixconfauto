# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, pkgs, lib, ... }:
let
  availableWMs = [
    { 
      name = "i3";
      type = "x11";
      desktopName = "i3";
      package = pkgs.i3;
    }
    { 
      name = "hyprland";
      type = "wayland";
      desktopName = "Hyprland";
      package = pkgs.hyprland;
    }
    { 
      name = "gnome";
      type = "x11";
      desktopName = "GNOME";
      package = pkgs.gnome.gnome-session;
    }
    { 
      name = "kde";
      type = "x11";
      desktopName = "KDE";
      package = pkgs.plasma5Packages.plasma-workspace;
    }
    { 
      name = "xorg";
      type = "x11";
      desktopName = "TWM";
      package = pkgs.xorg.twm;
    }
  ];

  selectedWM = lib.findFirst (wm: wm.name == config.defaultPrograms.windowManager) null availableWMs;
in {
  options = {
    defaultPrograms.windowManager = lib.mkOption {
      type = lib.types.enum (map (wm: wm.name) availableWMs ++ ["none"]);
      default = "none";
      description = "Default window manager or desktop environment to use";
    };
  };

  config = lib.mkIf (selectedWM != null) {
    home.sessionVariables = lib.mkMerge [
      # Common variables
      {
        XDG_CURRENT_DESKTOP = selectedWM.desktopName;
        XDG_SESSION_TYPE = selectedWM.type;
      }
      # Wayland-specific variables
      (lib.mkIf (selectedWM.type == "wayland") {
        NIXOS_OZONE_WL = "1";
        MOZ_ENABLE_WAYLAND = "1";
        QT_QPA_PLATFORM = "wayland";
        SDL_VIDEODRIVER = "wayland";
        _JAVA_AWT_WM_NONREPARENTING = "1";
      })
      # Desktop environment variables
      (lib.mkIf (selectedWM.name == "gnome" || selectedWM.name == "kde") {
        DESKTOP_SESSION = if selectedWM.name == "gnome" then "gnome" else "plasma";
      })
    ];
  };
}
