# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Script utilities wrapped in Nix functions
{ pkgs }:

let
  # Common utilities needed by our scripts
  scriptDeps = with pkgs; [
    coreutils
    gnused
    nixos-generate-config
  ];

  # Wrap a script with dependencies
  wrapScript = name: script: deps:
    pkgs.writeShellScriptBin name ''
      # Add dependencies to PATH
      export PATH="${pkgs.lib.makeBinPath deps}:$PATH"
      
      # Script content
      ${script}
    '';

  # Create home configuration script
  createHome = wrapScript "create-home" ''
    set -euo pipefail

    NIXCONF_DIR="$(cd "$(dirname "$0")/.." && pwd)"

    # Check arguments
    if [ $# -lt 2 ]; then
        echo "Usage: $0 <category> <username>"
        echo "Example: $0 personal adrian"
        echo "This will create homes/personal/adrian/"
        echo "The final username will be 'adrian-personal'"
        exit 1
    fi

    CATEGORY="$1"
    USERNAME="$2"
    TARGET_DIR="$NIXCONF_DIR/homes/$CATEGORY/$USERNAME"

    # Check if directory already exists
    if [ -d "$TARGET_DIR" ]; then
        echo "Error: Directory $TARGET_DIR already exists"
        exit 1
    fi

    # Create directory structure
    mkdir -p "$TARGET_DIR"

    # Copy template files
    cp "$NIXCONF_DIR/homes/template/default.nix" "$TARGET_DIR/"
    cp "$NIXCONF_DIR/homes/template/theme.nix" "$TARGET_DIR/"

    echo "Created new home configuration at $TARGET_DIR"
    echo "The username will be: $USERNAME-$CATEGORY"
    echo "Please customize the following files:"
    echo "  - $TARGET_DIR/default.nix (especially git.userName and git.userEmail)"
    echo "  - $TARGET_DIR/theme.nix"
  '' scriptDeps;

  # Create host configuration script
  createHost = wrapScript "create-host" ''
    set -euo pipefail

    NIXCONF_DIR="$(cd "$(dirname "$0")/.." && pwd)"

    # Check arguments
    if [ $# -lt 2 ]; then
        echo "Usage: $0 <category> <hostname>"
        echo "Example: $0 personal laptop"
        echo "This will create hosts/personal/laptop/"
        echo "The final hostname will be 'laptop-personal'"
        exit 1
    fi

    CATEGORY="$1"
    HOSTNAME="$2"
    TARGET_DIR="$NIXCONF_DIR/hosts/$CATEGORY/$HOSTNAME"

    # Check if directory already exists
    if [ -d "$TARGET_DIR" ]; then
        echo "Error: Directory $TARGET_DIR already exists"
        exit 1
    fi

    # Create directory structure
    mkdir -p "$TARGET_DIR"

    # Copy template files
    cp "$NIXCONF_DIR/hosts/template/default.nix" "$TARGET_DIR/"
    cp "$NIXCONF_DIR/hosts/template/theme.nix" "$TARGET_DIR/"

    echo "Created new host configuration at $TARGET_DIR"
    echo "The hostname will be: $HOSTNAME-$CATEGORY"
    echo
    echo "Next steps:"
    echo "1. Generate hardware configuration:"
    echo "   sudo nixos-generate-config --show-hardware-config > $TARGET_DIR/hardware-configuration.nix"
    echo
    echo "2. Choose a disk configuration by uncommenting one of:"
    echo "   - configs/hardware/disko/basic.nix"
    echo "   - configs/hardware/disko/encrypted.nix"
    echo "   - configs/hardware/disko/encrypted-yubikey.nix"
    echo
    echo "3. Customize these files:"
    echo "  - $TARGET_DIR/default.nix (system configuration)"
    echo "  - $TARGET_DIR/theme.nix (system-wide theme)"
  '' scriptDeps;

  # Sync dotfiles script
  syncDotfiles = wrapScript "sync-dotfiles" ''
    set -euo pipefail

    NIXCONF_DIR="$(cd "$(dirname "$0")/.." && pwd)"
    HOME_DIR="$HOME"

    # List of files to sync
    declare -A files_to_sync=(
      [".gitconfig"]="modules/home/programs/git.nix"
      [".zshrc"]="modules/home/programs/shell.nix"
      [".ssh/config"]="modules/home/programs/ssh.nix"
      [".config/alacritty/alacritty.yml"]="modules/home/programs/terminal.nix"
    )

    # Function to extract configuration from Nix files
    extract_config() {
      local file="$1"
      local content="$2"
      local nix_file="$3"
      
      echo "Syncing $file to $nix_file..."
      
      # Create backup
      cp "$NIXCONF_DIR/$nix_file" "$NIXCONF_DIR/$nix_file.bak"
      
      # TODO: Add specific extraction logic for each file type
      # This requires careful parsing of the file format and updating the Nix structure
      
      echo "Changes detected in $file. Please review and manually update $nix_file"
      echo "A backup has been created at $nix_file.bak"
    }

    # Check each file for changes
    for file in "''${!files_to_sync[@]}"; do
      nix_file="''${files_to_sync[$file]}"
      if [ -f "$HOME_DIR/$file" ]; then
        extract_config "$file" "$(cat "$HOME_DIR/$file")" "$nix_file"
      fi
    done

    echo "Done! Please review the changes and commit them to your Nix configuration."
  '' scriptDeps;
in {
  inherit createHome createHost syncDotfiles;
}
