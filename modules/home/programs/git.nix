# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Git configuration
{ config, pkgs, lib, ... }: {
  programs.git = {
    enable = true;
    userName = "Adrian Scarlett";
    userEmail = "adrian@scarlett.dev";
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "vim";
    };

    # Delta for better diffs
    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        side-by-side = true;
        line-numbers = true;
      };
    };

    # Useful aliases
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "!gitk";
    };

    # Signing commits (uncomment and configure)
    # signing = {
    #   key = "YOUR_GPG_KEY_ID";
    #   signByDefault = true;
    # };
  };
}
