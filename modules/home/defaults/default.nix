# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Default program selections and configurations
{ config, pkgs, lib, ... }: {
  imports = [
    # Core program defaults
    ./browsers.nix         # Browser selection
    ./window-managers.nix  # Window manager selection
    ./terminals.nix        # Terminal selection
    ./editors.nix          # Editor selection
    ./shells.nix          # Shell selection
  ];

  # XDG MIME type handling for default applications
  home.activation.setDefaultApplications = 
    let
      # Browser selection
      selectedBrowser = lib.findFirst 
        (b: b.name == config.defaultPrograms.browser)
        null
        (import ./browsers.nix { inherit config pkgs lib; }).availableBrowsers;

      # Terminal selection
      selectedTerminal = lib.findFirst
        (t: t.name == config.defaultPrograms.terminal)
        null
        (import ./terminals.nix { inherit config pkgs lib; }).availableTerminals;

      # Editor selection
      selectedEditor = lib.findFirst
        (e: e.name == config.defaultPrograms.editor)
        null
        (import ./editors.nix { inherit config pkgs lib; }).availableEditors;

    in lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Set default browser
      if [ -n "${toString (selectedBrowser.desktopFile or "")}" ]; then
        ${pkgs.xdg-utils}/bin/xdg-mime default ${selectedBrowser.desktopFile} x-scheme-handler/http
        ${pkgs.xdg-utils}/bin/xdg-mime default ${selectedBrowser.desktopFile} x-scheme-handler/https
      fi

      # Set default terminal
      if [ -n "${toString (selectedTerminal.desktopFile or "")}" ]; then
        ${pkgs.xdg-utils}/bin/xdg-mime default ${selectedTerminal.desktopFile} x-scheme-handler/terminal
      fi

      # Set default editor
      if [ -n "${toString (selectedEditor.desktopFile or "")}" ]; then
        ${pkgs.xdg-utils}/bin/xdg-mime default ${selectedEditor.desktopFile} text/plain
      fi
    '';
}
