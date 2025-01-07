# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Agenix for secret management
{
  agenix = {
    url = "github:ryantm/agenix";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.home-manager.follows = "home-manager"; # Optional: if you use home-manager integration
  };
}
