# Disko configurations
{ lib, ... }: {
  # Re-export both configurations
  basic = import ./basic.nix;
  advanced = import ./advanced.nix { inherit lib; };

  # Helper function to choose a configuration
  mkDisk = { 
    device, 
    type ? "basic",     # "basic" or "advanced"
    # Advanced options
    encryptionType ? "password",
    keyFile ? null,
    hostname ? "nixos",
  }: 
    if type == "basic" then
      (import ./basic.nix).mkDisk { inherit device; }
    else if type == "advanced" then
      (import ./advanced.nix { inherit lib; }).mkDisk {
        inherit device encryptionType keyFile hostname;
      }
    else
      throw "Unknown disk configuration type: ${type}";

  # Function to run disko with a given config
  runDisko = { 
    device,
    type ? "basic",
    encryptionType ? "password",
    keyFile ? null,
    hostname ? "nixos",
  }: let 
    pkgs = import <nixpkgs> {};
    config = mkDisk {
      inherit device type encryptionType keyFile hostname;
    };
  in pkgs.writeShellScriptBin "run-disko" ''
    set -e
    
    echo "About to format /dev/${device} with disko (${type} configuration)"
    echo "Current disk state:"
    lsblk "/dev/${device}"
    
    read -p "Are you sure you want to continue? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborting..."
        exit 1
    fi

    ${lib.optionalString (type == "advanced" && encryptionType == "yubikey") ''
      if [ ! -f "${keyFile}" ]; then
        echo "Error: Keyfile ${keyFile} not found"
        exit 1
      fi
    ''}
    
    ${pkgs.disko}/bin/disko --mode disko ${pkgs.writeText "disko-config.nix" (builtins.toJSON { disko.devices = config; })}
    
    echo "New disk state:"
    lsblk "/dev/${device}"
  '';
}
