#!/usr/bin/env bash

# Exit on error
set -e

# Get script directory
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
VM_DIR="$REPO_ROOT/.vm"
DISK_IMAGE="$VM_DIR/test-disk.qcow2"
ISO_PATH="$VM_DIR/nixos.iso"

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
        *)
            break
            ;;
    esac
done

# Handle disk image
if [[ ! -f "$DISK_IMAGE" ]] || [[ "$RESET" -eq 1 ]]; then
    echo "Creating new disk image..."
    qemu-img create -f qcow2 "$DISK_IMAGE" 20G
else
    echo "Using existing disk image. Use --reset to create a fresh one."
fi

# Download NixOS ISO if needed
if [[ ! -f "$ISO_PATH" ]]; then
    echo "Downloading NixOS minimal ISO..."
    # Use latest NixOS unstable for testing
    curl -L -o "$ISO_PATH" https://channels.nixos.org/nixos-unstable/latest-nixos-minimal-x86_64-linux.iso
fi

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
    -enable-kvm \
    -cpu host \
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

# Print instructions
echo
echo "VM is starting..."
echo "To connect with clipboard sharing:"
echo "1. Run: remote-viewer spice://localhost:5930"
echo
echo "To access the repo directory in the VM:"
echo "mkdir -p /mnt/host"
echo "mount -t 9p host /mnt/host -o trans=virtio,version=9p2000.L"
