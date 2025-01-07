# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

let
  # Import all input categories
  nixpkgs = import ./nixpkgs.nix;
  homeManager = import ./home-manager.nix;
  disko = import ./disko.nix;
  impermanence = import ./impermanence.nix;
  agenix = import ./agenix.nix;
  stylix = import ./stylix.nix;
in
  # Merge all inputs
  nixpkgs // homeManager // disko // impermanence // agenix // stylix
