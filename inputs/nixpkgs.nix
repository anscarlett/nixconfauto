# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

let
  versions = import ../versions.nix;
in
{
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-${versions.nixosRelease}";
}
