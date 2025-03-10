# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Disko utilities for disk formatting
{ lib, ... }: let
  diskoConfig = import ../hardware/disko/default.nix { inherit lib; };
in {
  # Re-export disko configurations
  basic = diskoConfig.basic;
  advanced = diskoConfig.advanced;

  # Disk formatting utilities
  utils = {
    # Basic disk formatting
    format-basic = {
      type = "app";
      program = (diskoConfig.runDisko {
        device = "vda";
        type = "basic";
      }).outPath + "/bin/run-disko";
    };

    # Encrypted disk formatting with password
    format-luks = {
      type = "app";
      program = (diskoConfig.runDisko {
        device = "vda";
        type = "advanced";
        encryptionType = "password";
      }).outPath + "/bin/run-disko";
    };

    # Encrypted disk formatting with Yubikey
    format-yubikey = {
      type = "app";
      program = (diskoConfig.runDisko {
        device = "vda";
        type = "advanced";
        encryptionType = "yubikey";
        keyFile = "/tmp/key.bin";
      }).outPath + "/bin/run-disko";
    };
  };
}
