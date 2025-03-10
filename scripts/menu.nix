# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

{ pkgs ? import <nixpkgs> { } }:

with pkgs;
let
  deps = [
    bash
    coreutils
    gnutar
    parted
    dosfstools
    e2fsprogs
    nixos-install-tools
    vim
  ];

  path = lib.makeBinPath deps;

  menu = writeScriptBin "nixconf-menu" ''
    #!${bash}/bin/bash
    export PATH="${path}:$PATH"n
    set -e

    # Colors
    BLUE='\033[0;34m'
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    NC='\033[0m'
    BOLD='\033[1m'

    # Clear screen
    clear_screen() {
      printf "\033c"
    }

    # Print header
    print_header() {
      echo -e "''${BLUE}''${BOLD}NixOS VM Installation''${NC}"
      echo -e "''${BLUE}===================''${NC}\n"
    }

    # Check if running as root
    if [ "$(id -u)" -ne 0 ]; then
      echo -e "''${RED}Error: This script must be run as root''${NC}"
      exit 1
    fi

    # Installation steps
    prepare_disk() {
      echo -e "\n''${BOLD}Preparing disk...''${NC}"
      
      if [ ! -e /dev/vda ]; then
        echo -e "''${RED}Error: /dev/vda not found. Are you running in a VM?''${NC}"
        exit 1
      fi
      
      echo "Creating partitions on /dev/vda..."
      parted /dev/vda -- mklabel gpt
      parted /dev/vda -- mkpart ESP fat32 1MB 512MB
      parted /dev/vda -- set 1 esp on
      parted /dev/vda -- mkpart primary 512MB 100%
      
      echo "Formatting partitions..."
      mkfs.fat -F 32 -n boot /dev/vda1
      mkfs.ext4 -L nixos /dev/vda2
      
      echo "Mounting partitions..."
      mount /dev/disk/by-label/nixos /mnt
      mkdir -p /mnt/boot
      mount /dev/disk/by-label/boot /mnt/boot
      
      echo -e "''${GREEN}Disk preparation complete!''${NC}"
    }

    generate_config() {
      echo -e "\n''${BOLD}Generating NixOS configuration...''${NC}"
      nixos-generate-config --root /mnt
      
      echo "Creating basic configuration..."
      cat > /mnt/etc/nixos/configuration.nix << 'EOL'
{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  services.openssh.enable = true;
  
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "nixos";
  };
  
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
EOL
      
      echo -e "''${GREEN}Configuration generated!''${NC}"
    }

    edit_config() {
      echo -e "\n''${BOLD}Opening configuration for editing...''${NC}"
      $EDITOR /mnt/etc/nixos/configuration.nix
    }

    install_system() {
      echo -e "\n''${BOLD}Installing NixOS...''${NC}"
      nixos-install --no-root-passwd
      
      echo -e "\n''${GREEN}Installation complete!''${NC}"
      echo -e "You can now:"
      echo "1. Reboot: shutdown -r now"
      echo "2. Log in as 'nixos' with password 'nixos'"
      echo "3. Clone your configuration and set up home-manager"
    }

    # Main menu
    main_menu() {
      while true; do
        clear_screen
        print_header
        
        echo "1) Prepare disk"
        echo "2) Generate configuration"
        echo "3) Edit configuration"
        echo "4) Install system"
        echo "q) Quit"
        echo
        
        read -p "Select an option: " choice
        echo
        
        case $choice in
          1)
            prepare_disk
            read -p "Press Enter to continue..."
            ;;
          2)
            generate_config
            read -p "Press Enter to continue..."
            ;;
          3)
            edit_config
            read -p "Press Enter to continue..."
            ;;
          4)
            install_system
            read -p "Press Enter to continue..."
            ;;
          q)
            echo -e "\nExiting..."
            exit 0
            ;;
          *)
            echo -e "''${RED}Invalid option''${NC}"
            sleep 1
            ;;
        esac
      done
    }

    # Trap cleanup
    trap 'echo -e "\n\nExiting..."; exit 0' INT

    # Start menu
    main_menu
  '';
in
menu

