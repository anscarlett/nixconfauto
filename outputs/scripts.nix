# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Script outputs
{ pkgs }:
let
  menu = import ../scripts/menu.nix { inherit pkgs; };
in {
  nixconfMenu = menu;
}
}
