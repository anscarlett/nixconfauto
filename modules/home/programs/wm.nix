# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Window manager configuration
{ config, pkgs, lib, ... }: {
  imports = [
    # Window Managers
    ./wm/i3.nix            # i3 window manager
    ./wm/hyprland.nix      # Hyprland compositor
    # Desktop Environments
    ./wm/gnome.nix         # GNOME desktop
    ./wm/kde.nix           # KDE Plasma desktop
    # Fallback
    ./wm/xorg.nix          # Xorg fallback configuration
  ];

  # Set environment variables based on selected window manager
  home.sessionVariables = let
    defaultWM = config.defaultPrograms.windowManager;
    isWayland = defaultWM == "hyprland";
    isX11 = defaultWM == "i3" || defaultWM == "xorg";
    isDesktop = defaultWM == "gnome" || defaultWM == "kde";
  in lib.mkMerge [
    # Wayland-specific variables
    (lib.mkIf isWayland {
      NIXOS_OZONE_WL = "1";  # Electron apps should use Wayland
      MOZ_ENABLE_WAYLAND = "1";  # Firefox should use Wayland
      QT_QPA_PLATFORM = "wayland";  # Qt should use Wayland
      SDL_VIDEODRIVER = "wayland";  # SDL should use Wayland
      _JAVA_AWT_WM_NONREPARENTING = "1";  # Fix Java apps under Wayland
      XDG_SESSION_TYPE = "wayland";
      XDG_CURRENT_DESKTOP = "Hyprland";
    })
    # X11-specific variables
    (lib.mkIf isX11 {
      XDG_SESSION_TYPE = "x11";
      XDG_CURRENT_DESKTOP = if defaultWM == "i3" then "i3" else "TWM";
    })
    # Desktop environment variables
    (lib.mkIf isDesktop {
      XDG_CURRENT_DESKTOP = if defaultWM == "gnome" then "GNOME" else "KDE";
      XDG_SESSION_TYPE = "x11";  # Most DEs still use X11 by default
      DESKTOP_SESSION = if defaultWM == "gnome" then "gnome" else "plasma";
    })
  ];

  # Common dependencies for all window managers and desktop environments
  home.packages = with pkgs; [
    # Application launchers
    rofi              # Application launcher
    dmenu             # Minimal launcher
    
    # System tray and notifications
    dunst             # Notification daemon
    libnotify         # Notification library
    
    # Display and compositing
    picom             # X11 compositor
    xorg.xrandr       # Display configuration
    arandr            # GUI for xrandr
    
    # Desktop utilities
    feh               # Image viewer and wallpaper setter
    nitrogen          # Wallpaper manager
    xclip             # Clipboard manager
    flameshot         # Screenshot tool
    
    # Status bars
    polybar           # Status bar for X11
    
    # Session management
    xorg.xauth        # X11 authentication
    xorg.xinit        # X11 initialization
    xorg.xrdb         # X resources database
    xorg.setxkbmap    # Keyboard layout configuration
    
    # System monitoring
    conky             # System monitor
    
    # Audio controls
    pavucontrol       # PulseAudio volume control
    pamixer           # CLI audio controls
  ];
}
