# Shared utility functions
{ lib, ... }: let
  disko = import ./disko.nix { inherit lib; };
in {
  inherit (disko) runDisko;

  # Function to create a NixOS system configuration
  mkSystem = { hostname, system ? "x86_64-linux" }: {
    # Basic system configuration will go here
  };

  # Function to create a home-manager configuration
  mkHome = { username, system ? "x86_64-linux" }: {
    # Basic home configuration will go here
  };
}
