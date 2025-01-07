# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# SSH configuration
{ config, pkgs, lib, ... }: {
  programs.ssh = {
    enable = true;
    
    matchBlocks = {
      # Example GitHub configuration
      "github.com" = {
        user = "git";
        identityFile = "~/.ssh/github";
      };

      # Example for work servers
      "*.work.com" = {
        user = "adrian";
        identityFile = "~/.ssh/work";
        extraOptions = {
          AddKeysToAgent = "yes";
          UseKeychain = "yes";
        };
      };
    };

    # Global SSH options
    extraConfig = ''
      AddKeysToAgent yes
      UseKeychain yes
      ServerAliveInterval 60
    '';
  };

  # Ensure SSH directory exists with correct permissions
  home.file.".ssh/".directory = {
    enable = true;
    mode = "0700";
  };

  # Add SSH key generation script
  home.file.".local/bin/generate-ssh-key" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      if [ $# -ne 2 ]; then
        echo "Usage: $0 <key-name> <email>"
        exit 1
      fi
      
      KEY_NAME="$1"
      EMAIL="$2"
      
      ssh-keygen -t ed25519 -C "$EMAIL" -f "$HOME/.ssh/$KEY_NAME"
      
      echo "SSH key generated:"
      echo "Private key: $HOME/.ssh/$KEY_NAME"
      echo "Public key:  $HOME/.ssh/$KEY_NAME.pub"
      
      if command -v pbcopy &> /dev/null; then
        cat "$HOME/.ssh/$KEY_NAME.pub" | pbcopy
        echo "Public key copied to clipboard!"
      else
        echo "Public key content:"
        cat "$HOME/.ssh/$KEY_NAME.pub"
      fi
    '';
  };
}
