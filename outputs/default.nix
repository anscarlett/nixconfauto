# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Flake outputs
{ self, nixpkgs, home-manager, disko }@inputs: let
  lib = nixpkgs.lib;
  
  # Import all output categories
  diskoOutputs = import ./disko.nix { inherit lib; };
  hostConfigs = import ./hostConfigurations.nix inputs;
  homeConfigs = import ./homeConfigurations.nix inputs;
  scriptOutputs = import ./scripts.nix inputs;
in
  # Merge all outputs
  diskoOutputs // {
    nixosConfigurations = hostConfigs;
    homeConfigurations = homeConfigs;
  } // scriptOutputs
