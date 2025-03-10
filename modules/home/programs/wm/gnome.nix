# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# GNOME configuration
{ config, pkgs, lib, ... }: {
  # Enable GNOME settings when selected
  config.dconf.enable = config.defaultPrograms.windowManager == "gnome" || config.dconf.enable;

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      enable-hot-corners = false;
      clock-show-weekday = true;
      clock-show-date = true;
      show-battery-percentage = true;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
      workspace-names = [ "Main" "Work" "Communication" "Media" ];
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-to-workspace-1 = ["<Super>1"];
      switch-to-workspace-2 = ["<Super>2"];
      switch-to-workspace-3 = ["<Super>3"];
      switch-to-workspace-4 = ["<Super>4"];
      move-to-workspace-1 = ["<Super><Shift>1"];
      move-to-workspace-2 = ["<Super><Shift>2"];
      move-to-workspace-3 = ["<Super><Shift>3"];
      move-to-workspace-4 = ["<Super><Shift>4"];
    };
  };

  # GNOME-specific packages
  home.packages = with pkgs; [
    gnome.gnome-tweaks
    gnome.dconf-editor
    gnomeExtensions.dash-to-dock
    gnomeExtensions.appindicator
    gnomeExtensions.gsconnect
  ];
}
