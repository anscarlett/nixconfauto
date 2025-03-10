# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Flake outputs
{ self, nixpkgs, home-manager, disko }@inputs:

let
  system = "x86_64-linux";
  pkgs = nixpkgs.legacyPackages.${system};
  
  # Import all output categories
  scriptOutputs = import ./scripts.nix { inherit pkgs; };
in
  # Return outputs
  {
    packages.${system} = {
      inherit (scriptOutputs) nixconfMenu;
      default = scriptOutputs.nixconfMenu;
    };
  }
