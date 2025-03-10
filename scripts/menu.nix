# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

{ pkgs ? import <nixpkgs> {} }:

with pkgs;
writeShellApplication {
  name = "nixos-install-menu";
  runtimeInputs = [
    coreutils
    parted
    dosfstools
    e2fsprogs
    nixos-install-tools
    vim
    util-linux # for lsblk
  ];
  text = ''

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'
BOLD='\033[1m'

# Track completed steps
DISK_PREPARED=0
CONFIG_GENERATED=0
CONFIG_EDITED=0

# Clear screen
clear_screen() {
  printf "\033c"
}

# Print header
print_step_status() {
  local step="$1"
  local desc="$2"
  local status="$3"
  local note="$4"
  
  printf "  %s %s" "$step" "$desc"
  printf "%*s" $((35 - ${#step} - ${#desc})) " "
  
  case "$status" in
    done)    echo -e "[${GREEN}✓${NC}] ${GREEN}Done${NC}" ;;
    pending) echo -e "[ ] ${YELLOW}Pending${NC}" ;;
    ready)   echo -e "[${GREEN}!${NC}] ${GREEN}Ready${NC}" ;;
    error)   echo -e "[${RED}!${NC}] ${RED}Failed${NC}" ;;
    skip)    echo -e "[-] ${YELLOW}Skipped${NC}" ;;
  esac
  
  if [ -n "$note" ]; then
    printf "%*s%s\n" 45 " " "$note"
  fi
}

print_header() {
  echo -e "\$BLUE\$BOLD"'NixOS Installation Menu'"\$NC"
  echo -e "\$BLUE"'===================='"\$NC\n"
  echo "This script will help you install NixOS on your system."
  echo "Requirements:"
  echo "  - Running as root"
  echo "  - A disk to install to"
  echo "  - Internet connection for downloading packages"
  echo
  echo "Installation Steps:"
  
  # Show step status
  if [ $DISK_PREPARED -eq 1 ]; then
    print_step_status "1)" "Prepare disk" "done"
  else
    print_step_status "1)" "Prepare disk" "pending" "Create partitions and filesystems"
  fi
  
  if [ $DISK_PREPARED -eq 0 ]; then
    print_step_status "2)" "Generate config" "skip" "Complete step 1 first"
  elif [ $CONFIG_GENERATED -eq 1 ]; then
    print_step_status "2)" "Generate config" "done"
  else
    print_step_status "2)" "Generate config" "pending" "Create NixOS configuration"
  fi
  
  if [ $CONFIG_GENERATED -eq 0 ]; then
    print_step_status "3)" "Edit config" "skip" "Complete step 2 first"
  elif [ $CONFIG_EDITED -eq 1 ]; then
    print_step_status "3)" "Edit config" "done"
  else
    print_step_status "3)" "Edit config" "pending" "Customize your system"
  fi
  
  if [ $DISK_PREPARED -eq 1 ] && [ $CONFIG_GENERATED -eq 1 ]; then
    print_step_status "4)" "Install NixOS" "ready" "Ready to install"
  else
    print_step_status "4)" "Install NixOS" "skip" "Complete steps 1-2 first"
  fi
  
  echo -e "\nq) Quit                  Exit installer\n"
}

# Check environment
if [ "$(id -u)" -ne 0 ]; then
  echo -e "\$RED"'Error: This script must be run as root'"\$NC"
  exit 1
fi

# Check if disk has mounted partitions
check_mounts() {
  local disk="$1"
  local mounted_parts
  mounted_parts=$(lsblk -n -o NAME,MOUNTPOINTS "/dev/$disk" | grep -v "^$disk" | grep -v "^$" | cut -d' ' -f2)
  if [ -n "$mounted_parts" ]; then
    echo -e "\$RED""Error: Some partitions are still mounted:""\$NC"
    echo "$mounted_parts"
    return 1
  fi
  return 0
}

# Check if disk is safe to use
check_disk_safety() {
  local disk="$1"
  
  # Check if disk exists
  if [ ! -e "/dev/$disk" ]; then
    echo -e "\$RED""Error: /dev/$disk not found""\$NC"
    return 1
  fi

  # Check if it's really a disk (not a partition)
  if ! lsblk -n -o TYPE "/dev/$disk" | grep -q "^disk$"; then
    echo -e "\$RED""Error: /dev/$disk is not a disk""\$NC"
    return 1
  fi

  # Check if disk is mounted
  if ! check_mounts "$disk"; then
    echo "Please unmount all partitions before continuing."
    return 1
  fi

  # Check disk size (minimum 2GB)
  local size_bytes
  size_bytes=$(lsblk -n -o SIZE -b "/dev/$disk" | head -n1)
  if [ "$size_bytes" -lt 2147483648 ]; then
    echo -e "\$RED""Error: Disk is too small (minimum 2GB required)""\$NC"
    return 1
  fi

  return 0
}

# Select installation disk
select_disk() {
  local selected_disk
  while true; do
    echo -e "\nAvailable disks:"
    echo -e "${BLUE}NAME     SIZE  MODEL${NC}"
    echo -e "------------------------"
    lsblk -n -o NAME,SIZE,MODEL,TYPE,MOUNTPOINTS | grep "disk" | sed 's/^/  /'
    echo -e "\nWARNING: The selected disk will be completely erased!"
    echo "Enter disk name (e.g. sda, vda, nvme0n1) or 'q' to quit: "
    read -p "> " selected_disk

    [ "$selected_disk" = "q" ] && exit 0

    if check_disk_safety "$selected_disk"; then
      echo -e "\n${YELLOW}WARNING: ALL data on /dev/$selected_disk will be erased!${NC}"
      echo "Disk details:"
      echo -e "${BLUE}Model:${NC}   $(lsblk -n -o MODEL "/dev/$selected_disk")"
      echo -e "${BLUE}Serial:${NC}  $(lsblk -n -o SERIAL "/dev/$selected_disk")"
      echo -e "${BLUE}Size:${NC}    $(lsblk -n -o SIZE "/dev/$selected_disk")"
      echo -e "${BLUE}Type:${NC}    $(lsblk -n -o TRAN "/dev/$selected_disk" || echo "unknown")\n"
      
      read -p "Type 'yes' to confirm disk selection: " confirm
      if [ "$confirm" = "yes" ]; then
        echo "$selected_disk"
        return 0
      fi
      echo "Disk selection cancelled."
    fi
  done
}

# Installation steps
# Wait for partition device to appear
wait_for_partition() {
  local disk="$1"
  local part_num="$2"
  local timeout=10
  local count=0

  while [ ! -e "/dev/${disk}${part_num}" ] && [ $count -lt $timeout ]; do
    sleep 1
    count=$((count + 1))
  done

  if [ ! -e "/dev/${disk}${part_num}" ]; then
    echo -e "\$RED""Error: Partition /dev/${disk}${part_num} not found after $timeout seconds""\$NC"
    return 1
  fi
  return 0
}

# Create and format partitions
prepare_disk() {
  echo -e "\n\$BOLD"'Preparing disk...'"\$NC"
  
  # Select disk to install to
  local disk
  disk=$(select_disk) || return 1
  
  echo "Creating partition table..."
  if ! parted "/dev/$disk" -- mklabel gpt; then
    echo -e "\$RED""Error: Failed to create GPT partition table""\$NC"
    return 1
  fi
  
  echo "Creating EFI system partition..."
  if ! parted "/dev/$disk" -- mkpart ESP fat32 1MB 512MB; then
    echo -e "\$RED""Error: Failed to create EFI partition""\$NC"
    return 1
  fi
  
  echo "Setting ESP flag..."
  if ! parted "/dev/$disk" -- set 1 esp on; then
    echo -e "\$RED""Error: Failed to set ESP flag""\$NC"
    return 1
  fi
  
  echo "Creating root partition..."
  if ! parted "/dev/$disk" -- mkpart primary 512MB 100%; then
    echo -e "\$RED""Error: Failed to create root partition""\$NC"
    return 1
  fi
  
  # Wait for partitions to appear
  echo "Waiting for partitions..."
  if ! wait_for_partition "$disk" "1" || ! wait_for_partition "$disk" "2"; then
    return 1
  fi
  
  echo "Formatting EFI partition..."
  if ! mkfs.fat -F 32 -n boot "/dev/${disk}1"; then
    echo -e "\$RED""Error: Failed to format EFI partition""\$NC"
    return 1
  fi
  
  echo "Formatting root partition..."
  if ! mkfs.ext4 -L nixos "/dev/${disk}2"; then
    echo -e "\$RED""Error: Failed to format root partition""\$NC"
    return 1
  fi
  
  echo "Mounting root partition..."
  if ! mount /dev/disk/by-label/nixos /mnt; then
    echo -e "\$RED""Error: Failed to mount root partition""\$NC"
    return 1
  fi
  
  echo "Mounting EFI partition..."
  mkdir -p /mnt/boot
  if ! mount /dev/disk/by-label/boot /mnt/boot; then
    echo -e "\$RED""Error: Failed to mount EFI partition""\$NC"
    umount /mnt
    return 1
  fi
  
  echo -e "\$GREEN"'Disk preparation complete!'"\$NC"
  DISK_PREPARED=1
}

generate_config() {
  echo -e "\n\$BOLD"'Generating NixOS configuration...'"\$NC"
  
  if [ ! -d "/mnt" ]; then
    echo -e "\$RED""Error: /mnt directory not found. Please prepare disk first.""\$NC"
    return 1
  fi

  echo "Generating hardware configuration..."
  if ! nixos-generate-config --root /mnt; then
    echo -e "\$RED""Error: Failed to generate hardware configuration""\$NC"
    return 1
  fi
  
  echo "Creating basic configuration..."
  cat > /mnt/etc/nixos/configuration.nix << 'EOL'
{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  # Boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Hardware support
  hardware.enableAllFirmware = true;
  services.fwupd.enable = true;  # Firmware updates
  
  # Power management
  powerManagement.enable = true;
  services.thermald.enable = true;  # CPU thermal management
  services.power-profiles-daemon.enable = true;  # Power profiles

  # Enable networking
  networking = {
    networkmanager.enable = true;  # User-friendly network manager
    firewall = {
      enable = true;
      allowPing = true;
    };
  };

  # Enable OpenSSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  # Set time zone
  time.timeZone = "UTC";

  # Sound
  sound.enable = true;
  hardware.pulseaudio.enable = false;  # Using pipewire instead
  security.rtkit.enable = true;  # Better real-time audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Create default user
  users.users.nixos = {
    isNormalUser = true;
    description = "NixOS User";
    extraGroups = [ 
      "wheel"           # Admin privileges
      "networkmanager"  # Network management
      "audio"          # Audio devices
      "video"          # Video devices
      "input"          # Input devices
    ];
    initialPassword = "nixos";
  };

  # Security
  security.sudo.wheelNeedsPassword = true;  # Require password for sudo

  # Enable Nix features
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@wheel" ];
      auto-optimise-store = true;
      warn-dirty = false;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages = with pkgs; [
    # System tools
    vim
    git
    curl
    wget
    htop
    pciutils      # PCI utilities
    usbutils      # USB utilities
    file          # File type info
    lm_sensors    # Hardware sensors
    dmidecode     # Hardware info
    smartmontools # Disk health monitoring

    # Archive formats
    zip
    unzip
    p7zip

    # Network tools
    dig           # DNS lookup
    whois
    traceroute
    nmap          # Network scanner
  ];

  # System settings
  system.stateVersion = "23.11";

  # Automatically optimize the Nix store
  nix.optimise.automatic = true;
}
EOL
  
  echo -e "\$GREEN"'Configuration generated!'"\$NC"
  CONFIG_GENERATED=1
}

edit_config() {
  echo -e "\n\$BOLD"'Opening configuration for editing...'"\$NC"
  $EDITOR /mnt/etc/nixos/configuration.nix
  CONFIG_EDITED=1
}

install_system() {
  echo -e "\n\$BOLD"'Installing NixOS...'"\$NC"
  
  # Check if disk is prepared
  if [ ! -d "/mnt/boot" ] || [ ! -d "/mnt/etc/nixos" ]; then
    echo -e "\$RED""Error: System not ready for installation""\$NC"
    echo "Please complete disk preparation and configuration steps first."
    return 1
  fi

  # Check if configuration exists
  if [ ! -f "/mnt/etc/nixos/configuration.nix" ] || [ ! -f "/mnt/etc/nixos/hardware-configuration.nix" ]; then
    echo -e "\$RED""Error: NixOS configuration files not found""\$NC"
    echo "Please generate configuration first."
    return 1
  fi

  # Check internet connection
  if ! ping -c 1 cache.nixos.org >/dev/null 2>&1; then
    echo -e "\$RED""Error: No internet connection""\$NC"
    echo "Please check your network connection and try again."
    return 1
  fi

  echo "Starting NixOS installation..."
  echo "This may take a while depending on your internet connection."
  echo "Installing packages and setting up the system..."
  
  if ! nixos-install --no-root-passwd; then
    echo -e "\$RED""Error: Installation failed""\$NC"
    echo "Check the error messages above for more details."
    return 1
  fi
  
  echo -e "\n\$GREEN"'Installation complete!'"\$NC"
  echo -e "\nNext steps:"
  echo "1. Reboot the system:     shutdown -r now"
  echo "2. Log in as:            nixos"
  echo "3. Default password:      nixos"
  echo "4. Change your password:  passwd"
  echo "\nImportant:"
  echo "- Remember to change the default password after first login"
  echo "- Your configuration is in /etc/nixos/configuration.nix"
}

# Print help
print_help() {
  echo -e "\n${BLUE}${BOLD}NixOS Installation Help${NC}"
  echo -e "${BLUE}===================${NC}\n"
  echo "This installer will help you set up NixOS on your system."
  echo
  echo "Installation Process:"
  echo "1. Prepare Disk"
  echo "   - Creates a GPT partition table"
  echo "   - Creates a 512MB EFI boot partition"
  echo "   - Uses remaining space for NixOS root"
  echo
  echo "2. Generate Config"
  echo "   - Creates hardware-specific configuration"
  echo "   - Sets up basic system services"
  echo "   - Configures bootloader and networking"
  echo
  echo "3. Edit Config"
  echo "   - Customize your configuration"
  echo "   - Add/remove packages"
  echo "   - Configure system services"
  echo
  echo "4. Install NixOS"
  echo "   - Installs the base system"
  echo "   - Sets up bootloader"
  echo "   - Creates initial user account"
  echo
  echo "Commands:"
  echo "  1-4  Execute the corresponding step"
  echo "  h    Show this help message"
  echo "  q    Exit the installer"
  echo
  read -p "Press Enter to return to menu..."
}

# Main menu
main_menu() {
  while true; do
    clear_screen
    print_header
    
    # Show step status
    if [ $DISK_PREPARED -eq 1 ]; then
      echo -e "\$GREEN✓\$NC 1) Prepare disk         - Partitions created & formatted"
    else
      echo -e "  1) Prepare disk         - Create & format partitions"
    fi

    if [ $CONFIG_GENERATED -eq 1 ]; then
      echo -e "\$GREEN✓\$NC 2) Generate config      - Basic config with VM tools"
    else
      echo -e "  2) Generate config      - Create NixOS configuration"
    fi

    if [ $CONFIG_EDITED -eq 1 ]; then
      echo -e "\$GREEN✓\$NC 3) Edit config          - Configuration customized"
    else
      echo -e "  3) Edit config          - Customize configuration"
    fi

    if [ $DISK_PREPARED -eq 1 ] && [ $CONFIG_GENERATED -eq 1 ]; then
      echo -e "  4) Install system       - Install NixOS\$GREEN (Ready)\$NC"
    else
      echo -e "  4) Install system       - Install NixOS\$YELLOW (Need steps 1-2)\$NC"
    fi

    echo -e "\nq) Quit                  - Exit installer"
    echo
    
    read -p "Select an option: " choice
    echo
    
    case $choice in
      1)
        if prepare_disk; then
          DISK_PREPARED=1
          echo -e "\n${GREEN}Disk preparation successful!${NC}"
          echo "Created:"
          echo "  - EFI System Partition (512MB)"
          echo "  - NixOS Root Partition (Remaining space)"
        else
          echo -e "\n${RED}Disk preparation failed${NC}"
        fi
        read -p "Press Enter to continue..."
        ;;
      2)
        if [ $DISK_PREPARED -eq 0 ]; then
          echo -e "${YELLOW}Warning: Please prepare disk first (Step 1)${NC}"
        elif generate_config; then
          CONFIG_GENERATED=1
          echo -e "\n${GREEN}Configuration generated successfully!${NC}"
          echo "Created:"
          echo "  - /mnt/etc/nixos/configuration.nix"
          echo "  - /mnt/etc/nixos/hardware-configuration.nix"
        else
          echo -e "\n${RED}Configuration generation failed${NC}"
        fi
        read -p "Press Enter to continue..."
        ;;
      3)
        if [ $CONFIG_GENERATED -eq 0 ]; then
          echo -e "${YELLOW}Warning: Please generate configuration first (Step 2)${NC}"
        else
          echo -e "\n${BLUE}Opening configuration in $EDITOR...${NC}"
          echo "Tip: Save and exit when done:"
          echo "  - In vim: press ESC, then :wq"
          echo "  - In nano: press Ctrl+X, Y, Enter"
          echo
          edit_config
          CONFIG_EDITED=1
          echo -e "\n${GREEN}Configuration updated!${NC}"
        fi
        read -p "Press Enter to continue..."
        ;;
      4)
        if [ $DISK_PREPARED -eq 0 ] || [ $CONFIG_GENERATED -eq 0 ]; then
          echo -e "${YELLOW}Warning: Please complete steps 1 and 2 before installing${NC}"
        else
          if install_system; then
            echo -e "\n${GREEN}NixOS installation completed successfully!${NC}"
          else
            echo -e "\n${RED}Installation failed${NC}"
          fi
        fi
        read -p "Press Enter to continue..."
        ;;
      h)
        print_help
        ;;
      q)
        echo -e "\nExiting NixOS installer..."
        exit 0
        ;;
      *)
        echo -e "${RED}Invalid option${NC}"
        echo "Type 'h' for help"
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
}
