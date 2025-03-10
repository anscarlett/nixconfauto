# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, pkgs, lib, ... }:
let
  availableEditors = [
    { 
      name = "neovim";
      package = pkgs.neovim;
      desktopFile = "nvim.desktop";
      mimeTypes = [ "text/plain" "text/x-*" ];
      command = "nvim";
    }
    { 
      name = "vscode";
      package = pkgs.vscodium;
      desktopFile = "code.desktop";
      mimeTypes = [ "text/plain" "text/x-*" ];
      command = "code";
    }
    { 
      name = "emacs";
      package = pkgs.emacs;
      desktopFile = "emacs.desktop";
      mimeTypes = [ "text/plain" "text/x-*" ];
      command = "emacs";
    }
  ];

  selectedEditor = lib.findFirst (ed: ed.name == config.defaultPrograms.editor) null availableEditors;
in {
  options = {
    defaultPrograms.editor = lib.mkOption {
      type = lib.types.enum (map (ed: ed.name) availableEditors ++ ["none"]);
      default = "none";
      description = "Default text editor to use";
    };
  };

  config = lib.mkIf (selectedEditor != null) {
    home.sessionVariables = {
      EDITOR = selectedEditor.command;
      VISUAL = selectedEditor.command;
    };
  };
}
