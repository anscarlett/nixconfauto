# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Home Manager configurations
{ self, nixpkgs, home-manager, ... }@inputs: let
  lib = nixpkgs.lib;
  utils = import ../utils/configurations.nix { inherit lib; };

  # Extra modules for Home Manager configurations
  homeModules = [
    # Default home configuration
    ../modules/home/default.nix

    # Add your common Home Manager modules here
    # Example:
    # ../modules/home/desktop.nix
  ];
in
  # Home Manager configurations
  # Example structure:
  # homes/
  #   ├── personal/
  #   │   └── adrian/default.nix -> adrian-personal
  #   └── work/
  #       └── adrian/default.nix -> adrian-work
  utils.makeConfigurations {
    path = ../homes;
    type = "home";
    inherit inputs;
    extraModules = homeModules;
  }
