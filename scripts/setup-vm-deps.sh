#!/usr/bin/env bash

# Exit on error
set -e

# Check if we're on NixOS
if [ -e /etc/NIXOS ]; then
    echo "Installing dependencies via NixOS configuration..."
    echo "Add this to your NixOS configuration:"
    echo
    echo "  environment.systemPackages = with pkgs; ["
    echo "    virt-manager"
    echo "    spice-gtk"
    echo "    spice"
    echo "    spice-protocol"
    echo "  ];"
    exit 0
fi

# For other Linux distributions, try to detect package manager
if command -v nix-env &> /dev/null; then
    echo "Installing dependencies via nix-env..."
    nix-env -iA nixpkgs.virt-manager nixpkgs.spice-gtk nixpkgs.spice nixpkgs.spice-protocol
elif command -v apt-get &> /dev/null; then
    echo "Installing dependencies via apt..."
    sudo apt-get update
    sudo apt-get install -y virt-manager spice-client-gtk
elif command -v dnf &> /dev/null; then
    echo "Installing dependencies via dnf..."
    sudo dnf install -y virt-manager spice-gtk3
elif command -v pacman &> /dev/null; then
    echo "Installing dependencies via pacman..."
    sudo pacman -S --needed virt-manager spice-gtk
else
    echo "Could not detect package manager. Please install:"
    echo "- virt-manager"
    echo "- spice-gtk"
    exit 1
fi

echo
echo "Dependencies installed! You can now:"
echo "1. Run ./scripts/test-vm.sh to start the VM"
echo "2. Run: remote-viewer spice://localhost:5930"
echo "3. Copy and paste will work between your host and the VM"
