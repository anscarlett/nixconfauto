# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Stylix for system-wide theming
{
  stylix = {
    url = "github:danth/stylix";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.home-manager.follows = "home-manager";
  };
}
