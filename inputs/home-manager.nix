# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Home Manager input
let
  versions = import ../versions.nix;
in
{
  home-manager = {
    url = "github:nix-community/home-manager/release-${versions.nixosRelease}";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
