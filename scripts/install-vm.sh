#!/usr/bin/env bash

# Exit on error
set -e

echo "=== NixOS VM Installation Helper ==="
echo "This script will help you install NixOS in the test VM."
echo ""

# Check if running in NixOS installation environment
if [ ! -e /etc/NIXOS ]; then
    echo "Error: This script must be run from the NixOS installation environment."
    echo "Please boot the VM and run this script there."
    exit 1
fi

# Create partitions
echo "=== Step 1: Creating partitions ==="
echo "Creating partitions on /dev/vda..."

# Create a new GPT partition table
parted /dev/vda -- mklabel gpt

# Create boot partition (512MB)
parted /dev/vda -- mkpart ESP fat32 1MB 512MB
parted /dev/vda -- set 1 esp on

# Create root partition (rest of disk)
parted /dev/vda -- mkpart primary 512MB 100%

# Format partitions
echo "Formatting partitions..."
mkfs.fat -F 32 -n boot /dev/vda1
mkfs.ext4 -L nixos /dev/vda2

# Mount partitions
echo "Mounting partitions..."
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot

# Generate initial config
echo "=== Step 2: Generating NixOS configuration ==="
nixos-generate-config --root /mnt

# Clone our configuration
echo "=== Step 3: Setting up our configuration ==="
echo "Cloning configuration repository..."
nix-env -iA nixos.git
git clone https://github.com/yourusername/nixconf.git /mnt/etc/nixos/nixconf

# Create basic configuration
cat > /mnt/etc/nixos/configuration.nix << 'EOL'
{ config, pkgs, ... }:

{
  imports = [ ./nixconf/modules/system/default.nix ];
  
  # Basic system configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Enable OpenSSH daemon
  services.openssh.enable = true;
  
  # Create user account
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "nixos";
  };
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
EOL

echo ""
echo "=== Next Steps ==="
echo "1. Review and customize /mnt/etc/nixos/configuration.nix"
echo "2. Run: nixos-install"
echo "3. After installation, reboot and log in as 'nixos' with password 'nixos'"
echo "4. Clone your configuration and set up home-manager"
