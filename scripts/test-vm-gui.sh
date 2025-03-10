#!/usr/bin/env bash

# Usage information
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Start a NixOS VM for testing configurations"
    echo ""
    echo "Options:"
    echo "  --reset    Create a fresh disk image"
    echo "  --help     Show this help message"
    echo ""
    echo "The VM will start with:"
    echo "- Username: nixos (no password required)"
    echo "- SSH port: 2222 (ssh -p 2222 nixos@localhost)"
    echo "- Shared folder: /mnt/host (mount -t 9p host /mnt/host -o trans=virtio)"
    exit 0
}

# Exit on error
set -e

# Get script directory
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
VM_DIR="$REPO_ROOT/.vm"
DISK_IMAGE="$VM_DIR/test-disk.qcow2"
ISO_PATH="$VM_DIR/nixos.iso"

# Check if required commands are available
check_command() {
    local cmd=$1
    local pkg=${2:-$1}
    
    if ! command -v "$cmd" &> /dev/null; then
        echo "Required command '$cmd' not found."
        echo "Please install it using your system's package manager."
        echo "For example:"
        echo "  - Debian/Ubuntu: sudo apt install $pkg"
        echo "  - Fedora: sudo dnf install $pkg"
        echo "  - Arch: sudo pacman -S $pkg"
        echo "  - NixOS: nix-env -iA nixos.$pkg"
        exit 1
    fi
}

# Check for required commands
check_command qemu-system-x86_64 qemu
check_command remote-viewer virt-viewer
check_command qemu-img qemu-utils

# Check for KVM support
if [ -c /dev/kvm ] && [ -w /dev/kvm ]; then
    echo "KVM acceleration available"
    KVM_ARGS="-enable-kvm -cpu host"
else
    echo "Warning: KVM not available, VM will be slower"
    KVM_ARGS=""
fi

# Ensure clean shutdown
cleanup() {
    echo "\nCleaning up..."
    pkill -f "remote-viewer.*localhost:5930" || true
    pkill -f "qemu-system-x86_64.*$DISK_IMAGE" || true
    sleep 1  # Give processes time to clean up
    exit 0
}
trap cleanup EXIT INT TERM

# Kill any existing QEMU processes using our disk image
echo "Checking for existing VM processes..."
if pgrep -f "qemu-system-x86_64.*$DISK_IMAGE" > /dev/null; then
    echo "Found existing VM using the disk image, cleaning up..."
    pkill -f "qemu-system-x86_64.*$DISK_IMAGE"
    sleep 2  # Give more time for cleanup
    
    # Double check if process is gone
    if pgrep -f "qemu-system-x86_64.*$DISK_IMAGE" > /dev/null; then
        echo "Failed to stop existing VM. Please manually stop it:"
        echo "pkill -f 'qemu-system-x86_64.*$DISK_IMAGE'"
        exit 1
    fi
fi

# Create VM directory if it doesn't exist
mkdir -p "$VM_DIR"

# Parse arguments
RESET=0
while [[ $# -gt 0 ]]; do
    case $1 in
        --reset)
            RESET=1
            shift
            ;;
        --help)
            show_usage
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Handle disk image
if [[ -f "$DISK_IMAGE" ]] && [[ "$RESET" -eq 1 ]]; then
    echo "Removing existing disk image..."
    rm -f "$DISK_IMAGE"
fi

if [[ ! -f "$DISK_IMAGE" ]]; then
    if [[ "$RESET" -eq 1 ]]; then
        echo "Creating fresh disk image (--reset specified)..."
    else
        echo "No existing disk image found, creating new one..."
    fi
    qemu-img create -f qcow2 "$DISK_IMAGE" 20G
else
    echo "Using existing disk image at $DISK_IMAGE"
    echo "Use --reset to create a fresh one if needed."
fi

# Download NixOS ISO if needed
if [[ ! -f "$ISO_PATH" ]]; then
    echo "Downloading NixOS minimal ISO..."
    curl -L -o "$ISO_PATH" https://channels.nixos.org/nixos-unstable/latest-nixos-minimal-x86_64-linux.iso
fi

# Function to start SPICE viewer
start_viewer() {
    echo "Starting SPICE viewer..."
    if ! DISPLAY=":0" remote-viewer spice://localhost:5930 2>/dev/null & then
        echo "Warning: Failed to start SPICE viewer. You can:"
        echo "1. Start it manually: remote-viewer spice://localhost:5930"
        echo "2. Use SSH instead: ssh -p 2222 nixos@localhost"
    fi
}

# Print VM access information
echo "=== NixOS Test VM ==="
echo "VM is starting with:"
echo "- Username: nixos"
echo "- Password: empty (no password required)"
echo ""
echo "Access methods:"
echo "1. GUI: Will open automatically (or run: remote-viewer spice://localhost:5930)"
echo "2. SSH: ssh -p 2222 nixos@localhost"
echo "3. Shared folder: Will be available at /mnt/host in the VM"
echo ""

# Start viewer in background
(sleep 5 && start_viewer) &


# Start QEMU with:
# - Our test disk
# - NixOS minimal ISO
# - 4GB RAM
# - 4 cores
# - Enable KVM if available
# - Forward SSH port
# - Enable SPICE for clipboard sharing
# - Share repo directory via 9p
exec qemu-system-x86_64 \
    $KVM_ARGS \
    -m 4G \
    -smp 4 \
    -drive file="$DISK_IMAGE",if=virtio \
    -drive file="$ISO_PATH",media=cdrom \
    -boot order=d,menu=on \
    -net nic,model=virtio \
    -net user,hostfwd=tcp::2222-:22 \
    -vga qxl \
    -device virtio-serial-pci \
    -spice port=5930,disable-ticketing=on \
    -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
    -chardev spicevmc,id=spicechannel0,name=vdagent \
    -virtfs local,path="$REPO_ROOT",mount_tag=host,security_model=passthrough,id=host \
    "${@}"
