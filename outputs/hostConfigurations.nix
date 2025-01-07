# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# NixOS host configurations
{ self, nixpkgs, ... }@inputs: let
  lib = nixpkgs.lib;
  utils = import ../utils/configurations.nix { inherit lib; };

  # Extra modules for NixOS configurations
  nixosModules = [
    # Default applications for all hosts
    ../modules/nixos/default-apps.nix

    # Add other common NixOS modules here
    # Example:
    # ../modules/nixos/desktop.nix
  ];
in
  # NixOS configurations
  # Example structure:
  # hosts/
  #   ├── personal/
  #   │   └── laptop/default.nix -> laptop-personal
  #   └── work/
  #       └── desktop/default.nix -> desktop-work
  utils.makeConfigurations {
    path = ../hosts;
    type = "nixos";
    inherit inputs;
    extraModules = nixosModules;
  }
