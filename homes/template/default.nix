# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Template for user customization
{ config, pkgs, lib, inputs, ... }: {
  imports = [ ./theme.nix ];

  # User-specific configuration
  home = {
    # Username and homeDirectory are set automatically by makeConfigurations
    # based on the folder structure (e.g., homes/personal/adrian -> adrian-personal)
    stateVersion = "24.11";

    # Default packages for all users
    packages = with pkgs; [
      ripgrep
      fd
      bat
      exa
      jq
      htop
      tree
    ];
  };

  # Default programs configuration
  programs = {
    git = {
      # Git config should be customized per user
      userName = "CHANGE_ME";
      userEmail = "CHANGE_ME";
    };

    # Browser preference
    firefox.enable = true;
    chromium.enable = false;

    # Editor preference
    neovim.enable = true;
    vscode.enable = false;
    emacs.enable = false;

    # Terminal preference
    alacritty.enable = true;
    kitty.enable = false;
    wezterm.enable = false;

    # Shell preference
    zsh.enable = true;
    fish.enable = false;
    bash.enable = true; # Recommended to keep as fallback
  };

  # SSH Keys
  programs.ssh.matchBlocks = {
    "github.com" = {
      user = "git";
      identityFile = "~/.ssh/github";
    };
  };

  # Window Manager preference
  windowManager = {
    i3.enable = false;
    sway.enable = false;
    hyprland.enable = true;
  };
}
