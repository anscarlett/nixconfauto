# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Script outputs
{ self, nixpkgs, ... }@inputs:
let
  system = "x86_64-linux";
  pkgs = nixpkgs.legacyPackages.${system};
  scripts = import ../modules/scripts { inherit pkgs; };
in {
  # Make scripts available as flake apps
  apps.${system} = {
    create-home = {
      type = "app";
      program = "${scripts.createHome}/bin/create-home";
    };
    create-host = {
      type = "app";
      program = "${scripts.createHost}/bin/create-host";
    };
    sync-dotfiles = {
      type = "app";
      program = "${scripts.syncDotfiles}/bin/sync-dotfiles";
    };
  };

  # Also expose the scripts as packages
  packages.${system} = {
    inherit (scripts) createHome createHost syncDotfiles;
  };
}
