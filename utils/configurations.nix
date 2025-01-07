# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Configuration generation utilities
{ lib, ... }: let
  inherit (builtins) readDir attrNames;
  inherit (lib) filterAttrs hasPrefix hasSuffix removeSuffix;

  # Get all directories in a path
  getDirectories = path:
    filterAttrs (name: type: type == "directory") (readDir path);

  # Convert path components to a name (e.g., ["home" "adrian"] -> "adrian-home")
  pathToName = components:
    lib.concatStringsSep "-" (lib.reverseList components);

  # Scan a directory recursively and build a list of paths
  # Returns a list of { name = "reversed-path-name"; path = "/full/path"; components = ["path" "components"]; }
  scanDirectory = path: let
    # Helper function to scan recursively
    scan = current: components:
      let
        dirs = getDirectories current;
        # Check if this directory contains a default.nix
        hasConfig = builtins.pathExists (current + "/default.nix");
        # Create entry if we found a config
        entry = if hasConfig 
          then [{ 
            name = pathToName components;
            path = current;
            components = components;
          }]
          else [];
        # Recursively scan subdirectories
        subdirs = lib.flatten (
          lib.mapAttrsToList (name: _:
            scan (current + "/${name}") (components ++ [name])
          ) dirs
        );
      in
        entry ++ subdirs;
  in
    scan path [];

  # Generate configurations from a directory
  # type: "nixos" or "home"
  makeConfigurations = { 
    path,            # Base path to scan
    type,           # "nixos" or "home"
    inputs,         # Flake inputs
    extraModules ? [] # Additional modules to include
  }:
    let
      # Scan directory for configurations
      configs = scanDirectory path;
      
      # Create a configuration for each entry
      mkConfig = { name, path, components }: {
        ${name} = 
          if type == "nixos" then
            inputs.nixpkgs.lib.nixosSystem {
              system = "x86_64-linux";
              modules = [
                (path + "/default.nix")
                {
                  networking.hostName = name;
                }
              ] ++ extraModules;
              specialArgs = { inherit inputs; };
            }
          else
            inputs.home-manager.lib.homeManagerConfiguration {
              pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
              modules = [
                (path + "/default.nix")
                {
                  home = {
                    username = name;
                    homeDirectory = "/home/${name}";
                  };
                }
              ] ++ extraModules;
              extraSpecialArgs = { inherit inputs; };
            };
      };
    in
      lib.listToAttrs (map (entry: {
        name = entry.name;
        value = (mkConfig entry).${entry.name};
      }) configs);
in {
  inherit makeConfigurations;
}
