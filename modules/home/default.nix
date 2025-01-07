# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Default home configuration
{ config, pkgs, lib, ... }: {
  imports = [
    ../theme                   # Stylix theme configuration
    ./programs/git.nix
    ./programs/terminal.nix
    ./programs/shell.nix
    ./programs/browser.nix
    ./programs/editor.nix
    ./programs/wm.nix
    ./programs/ssh.nix
  ];

  # Enable home-manager
  programs.home-manager.enable = true;

  # Default XDG directories
  xdg = {
    enable = true;
    userDirs.enable = true;
  };
}
