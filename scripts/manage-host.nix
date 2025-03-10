# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

{ pkgs ? import <nixpkgs> { } }:

let
  name = "manage-host";
  script = pkgs.writeShellScriptBin name ''
    set -e

    function print_usage() {
      echo "Usage: $0 <command> [options]"
      echo ""
      echo "Commands:"
      echo "  create <hostname>    Create a new host configuration"
      echo "  install <hostname>   Install NixOS on a new system"
      echo ""
      echo "Examples:"
      echo "  $0 create my-laptop"
      echo "  $0 install my-laptop"
    }

    function create_host() {
      local hostname=$1
      if [ -z "$hostname" ]; then
        echo "Error: Hostname is required"
        print_usage
        exit 1
      fi

      local host_dir="hosts/$hostname"
      if [ -d "$host_dir" ]; then
        echo "Error: Host $hostname already exists"
        exit 1
      fi

      echo "Creating new host: $hostname"
      cp -r hosts/template "$host_dir"
      
      # Update hostname in configuration
      sed -i "s/networking.hostName = \".*\"/networking.hostName = \"$hostname\"/" "$host_dir/default.nix"
      
      echo "Host $hostname created successfully!"
      echo "Next steps:"
      echo "1. Edit $host_dir/default.nix to customize your configuration"
      echo "2. Generate hardware configuration: nixos-generate-config --dir $host_dir"
      echo "3. Choose your disk configuration from hardware/disko/"
    }

    function install_host() {
      local hostname=$1
      if [ -z "$hostname" ]; then
        echo "Error: Hostname is required"
        print_usage
        exit 1
      fi

      local host_dir="hosts/$hostname"
      if [ ! -d "$host_dir" ]; then
        echo "Error: Host $hostname does not exist"
        exit 1
      fi

      echo "Installing NixOS for host: $hostname"
      echo "This will:"
      echo "1. Format disks according to your disko configuration"
      echo "2. Install NixOS with your configuration"
      echo ""
      read -p "Are you sure you want to continue? [y/N] " -n 1 -r
      echo
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
      fi

      # Format disks using disko
      echo "Formatting disks..."
      sudo nix run github:nix-community/disko -- --mode disko ".#$hostname"

      # Install NixOS
      echo "Installing NixOS..."
      sudo nixos-install --flake ".#$hostname"

      echo "Installation complete!"
      echo "You can now reboot into your new system"
    }

    case "$1" in
      "create")
        create_host "$2"
        ;;
      "install")
        install_host "$2"
        ;;
      *)
        print_usage
        exit 1
        ;;
    esac
  '';
in pkgs.symlinkJoin {
  inherit name;
  paths = [ script ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = "wrapProgram $out/bin/${name} --prefix PATH : ${pkgs.lib.makeBinPath [
    pkgs.coreutils
    pkgs.gnused
    pkgs.nixos-install-tools
  ]}";
}
