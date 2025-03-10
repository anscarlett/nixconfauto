# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, pkgs, lib, ... }:
let
  availableTerminals = [
    { 
      name = "alacritty";
      package = pkgs.alacritty;
      desktopFile = "alacritty.desktop";
      mimeTypes = [ "x-scheme-handler/terminal" ];
    }
    { 
      name = "kitty";
      package = pkgs.kitty;
      desktopFile = "kitty.desktop";
      mimeTypes = [ "x-scheme-handler/terminal" ];
    }
    { 
      name = "urxvt";
      package = pkgs.rxvt-unicode;
      desktopFile = "urxvt.desktop";
      mimeTypes = [ "x-scheme-handler/terminal" ];
    }
  ];

  selectedTerminal = lib.findFirst (term: term.name == config.defaultPrograms.terminal) null availableTerminals;
in {
  options = {
    defaultPrograms.terminal = lib.mkOption {
      type = lib.types.enum (map (term: term.name) availableTerminals ++ ["none"]);
      default = "none";
      description = "Default terminal emulator to use";
    };
  };

  config = lib.mkIf (selectedTerminal != null) {
    home.sessionVariables = {
      TERMINAL = selectedTerminal.name;
      DEFAULT_TERMINAL = selectedTerminal.name;
    };
  };
}
