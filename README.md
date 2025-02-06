# NixOS Configuration

A modular and well-organized NixOS configuration system using flakes.

## Installation

### From NixOS Live ISO

1. Boot from a NixOS installation media
2. Clone this repository:
```bash
git clone https://github.com/yourusername/nixconf
cd nixconf
```

3. Create your hardware configuration:
```bash
# Generate hardware configuration for the current system
sudo nixos-generate-config --dir hosts/my-hostname
```

4. Choose your disk configuration in `hosts/my-hostname/default.nix`:
   - Basic: `configs/hardware/disko/basic.nix`
   - Encrypted: `configs/hardware/disko/encrypted.nix`
   - Encrypted with YubiKey: `configs/hardware/disko/encrypted-yubikey.nix`

5. Install NixOS with your configuration:
```bash
# Format disks according to your disko configuration
sudo nix run github:nix-community/disko -- --mode disko hosts/my-hostname/disk-config.nix

# Install NixOS with your configuration
sudo nixos-install --flake .#my-hostname
```

6. After installation, reboot into your new system

### Testing in a VM

To test in a VM before installing on real hardware:

1. Boot from NixOS installation media in a VM
2. Follow the same steps as above, but ensure your hardware configuration matches your VM setup

## Structure

```
.
├── configs/       # Shared configuration presets
├── homes/        # Home-manager configurations
├── hosts/        # Host-specific configurations
├── inputs/       # Flake inputs and dependencies
├── modules/      # Custom NixOS modules
├── outputs/      # Flake outputs
├── scripts/      # Utility scripts
└── utils/        # Helper functions and utilities
```

### Key Components

- **configs/**: Common configuration presets for hardware, desktop environments, and system services
- **homes/**: User-specific configurations managed by home-manager
- **hosts/**: Individual machine configurations, with `template/` as a base reference
- **inputs/**: External dependencies and flake inputs
- **modules/**: Custom NixOS modules for system configuration
- **outputs/**: Flake output definitions for system configurations
- **scripts/**: Utility scripts for system management
- **utils/**: Helper functions and utilities for the configuration

## Getting Started

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd nixconf
   ```

2. Create a new host configuration:
   - Copy the template directory: `cp -r hosts/template hosts/your-hostname`
   - Modify `hosts/your-hostname/default.nix` for your system
   - Generate hardware configuration: `nixos-generate-config --dir hosts/your-hostname`

3. Choose your disk configuration in `hosts/your-hostname/default.nix`:
   - Basic: `configs/hardware/disko/basic.nix`
   - Encrypted: `configs/hardware/disko/encrypted.nix`
   - Encrypted with YubiKey: `configs/hardware/disko/encrypted-yubikey.nix`

4. Configure your system:
   - Hardware settings (CPU, GPU, sound, etc.)
   - Boot loader options
   - System services
   - User configurations via home-manager

## Quick Start

Enter the development shell to access the interactive menu:
```bash
nix-shell
```

The menu system will automatically start and provide options to:
- Manage Hosts (create, install, list)
- Manage Users (create, switch, list)

You can also run individual commands directly:

### Managing Hosts

Create a new host:
```bash
manage-host create my-laptop
```

Install NixOS on a new system:
```bash
manage-host install my-laptop
```

### Managing Users

Create a new user configuration:
```bash
manage-user create john
```

Switch to a user's configuration:
```bash
manage-user switch john
```

## Usage

### Building and Activating

```bash
# Build your system configuration
nixos-rebuild build --flake .#hostname

# Switch to the new configuration
nixos-rebuild switch --flake .#hostname
```

### Home Manager

User configurations are managed through home-manager. Modify your user configuration in the `homes/` directory.

```bash
# Build home configuration
home-manager build --flake .#username@hostname

# Switch to new home configuration
home-manager switch --flake .#username@hostname
```

## Customization

### Adding New Modules

1. Create a new module in `modules/`
2. Import it in your host configuration or make it available through `outputs/`

### Creating Custom Configurations

1. Add configuration presets in `configs/`
2. Import them in your host configuration

## License

GPL-3.0-only

## Last Updated

2025-01-29
