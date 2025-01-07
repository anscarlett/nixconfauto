# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Validation for disk configuration imports
{ config, lib, ... }:

with lib;

let
  cfg = config.system.disk;
  
  # List of valid disk configurations
  validDiskoConfigs = [
    "configs/hardware/disko/basic.nix"
    "configs/hardware/disko/encrypted.nix"
    "configs/hardware/disko/encrypted-yubikey.nix"
  ];

  # Function to check if a module is imported
  isModuleImported = module:
    any (i: hasSuffix module (toString i)) config.imports;

  # Check if any of the valid disko configs are imported
  hasValidDiskoConfig = any isModuleImported validDiskoConfigs;
in {
  options.system.disk = {
    validationEnabled = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Whether to validate disk configuration imports.
        Set to false only if you have a custom disk configuration.
      '';
    };
  };

  config = mkIf cfg.validationEnabled {
    assertions = [
      {
        assertion = hasValidDiskoConfig;
        message = ''
          No valid disk configuration found in imports.
          Please uncomment one of the following in your configuration:
          ${concatMapStrings (cfg: "  - " + cfg + "\n") validDiskoConfigs}
          If you're using a custom disk configuration, set system.disk.validationEnabled = false;
        '';
      }
    ];

    warnings = mkIf (!hasValidDiskoConfig) [
      ''
        Warning: No standard disk configuration detected.
        If you're not using a custom configuration, please import one of:
        ${concatMapStrings (cfg: "  - " + cfg + "\n") validDiskoConfigs}
      ''
    ];
  };
}
