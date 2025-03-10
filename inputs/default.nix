# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

let
  # Import all input configurations
  nixpkgs = import ./nixpkgs.nix;
  home-manager = import ./home-manager.nix;
  disko = import ./disko.nix;
  agenix = import ./agenix.nix;
  impermanence = import ./impermanence.nix;
  stylix = import ./stylix.nix;
in
# Merge all inputs into a single attribute set
nixpkgs // home-manager // disko // agenix // impermanence // stylix
