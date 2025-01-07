# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Disk formatting outputs
{ lib, ... }: let
  diskoUtils = import ../utils/disko.nix { inherit lib; };
in {
  # Re-export disko configurations
  basic = diskoUtils.basic;
  advanced = diskoUtils.advanced;

  # Standard flake app outputs for disk formatting utilities
  apps.x86_64-linux = diskoUtils.utils;
}
