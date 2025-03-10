# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, pkgs, lib, ... }:
let
  availableShells = [
    { 
      name = "bash";
      package = pkgs.bash;
      command = "bash";
      path = "/run/current-system/sw/bin/bash";
    }
    { 
      name = "zsh";
      package = pkgs.zsh;
      command = "zsh";
      path = "/run/current-system/sw/bin/zsh";
    }
    { 
      name = "fish";
      package = pkgs.fish;
      command = "fish";
      path = "/run/current-system/sw/bin/fish";
    }
  ];

  selectedShell = lib.findFirst (sh: sh.name == config.defaultPrograms.shell) null availableShells;
in {
  options = {
    defaultPrograms.shell = lib.mkOption {
      type = lib.types.enum (map (sh: sh.name) availableShells ++ ["none"]);
      default = "none";
      description = "Default shell to use";
    };
  };

  config = lib.mkIf (selectedShell != null) {
    home.sessionVariables = {
      SHELL = selectedShell.path;
    };
  };
}
