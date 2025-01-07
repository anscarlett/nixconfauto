# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Default applications included in all NixOS hosts
{ pkgs, ... }: {
  # Essential command line tools
  environment.systemPackages = with pkgs; [
    # Version Control
    git

    # Text Editor
    vim

    # Network Tools
    curl
  ];

  # Documentation for included packages
  documentation = {
    enable = true;
    man = {
      enable = true;
      generateCaches = true;
    };
    doc.enable = true;
  };

  # Default shell aliases
  environment.shellAliases = {
    g = "git";
    v = "vim";
  };

  # Default git configuration
  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };
}
