# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Impermanence for ephemeral root configuration
{
  impermanence = {
    url = "github:nix-community/impermanence";
    # No need for nixpkgs.follows since it's just modules
  };
}
