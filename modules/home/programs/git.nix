# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Git configuration
{ config, pkgs, lib, ... }: {
  options.home.git = {
    pull = {
      rebase = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to rebase instead of merge when pulling";
      };
    };
    push = {
      autoSetupRemote = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to automatically set up remote tracking branches";
      };
    };
    delta = {
      enable = lib.mkEnableOption "Enable delta for git diffs";
      options = lib.mkOption {
        type = lib.types.attrsOf lib.types.bool;
        default = {
          navigate = true;
          light = false;
          side-by-side = true;
          line-numbers = true;
        };
        description = "Delta options for git diff viewing";
      };
    };
    userName = lib.mkOption {
      type = lib.types.str;
      description = "Git user name";
      example = "John Doe";
    };
    userEmail = lib.mkOption {
      type = lib.types.str;
      description = "Git user email";
      example = "john@example.com";
    };
    defaultBranch = lib.mkOption {
      type = lib.types.str;
      default = "main";
      description = "Default branch name for new repositories";
    };
    editor = lib.mkOption {
      type = lib.types.str;
      default = let
        editor = config.defaultPrograms.editor;
      in if editor == "none" then "vi"
         else if editor == "neovim" then "nvim"
         else if editor == "vscode" then "code --wait"
         else if editor == "emacs" then "emacs"
         else editor;
      description = "Default editor for git commit messages";
    };
    aliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        visual = "!gitk";
      };
      description = "Git command aliases";
    };
    signing = {
      enable = lib.mkEnableOption "Enable commit signing with GPG";
      key = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "GPG key ID for signing commits";
        example = "1234567890ABCDEF";
      };
    };
  };

  programs.git = {
    enable = true;
    userName = config.home.git.userName;
    userEmail = config.home.git.userEmail;
    
    extraConfig = {
      init.defaultBranch = config.home.git.defaultBranch;
      pull.rebase = config.home.git.pull.rebase;
      push.autoSetupRemote = config.home.git.push.autoSetupRemote;
      core.editor = config.home.git.editor;
    };

    # Delta for better diffs
    delta = lib.mkIf config.home.git.delta.enable {
      enable = true;
      options = config.home.git.delta.options;
    };

    # Useful aliases
    aliases = config.home.git.aliases;

    # Signing commits
    signing = lib.mkIf config.home.git.signing.enable {
      key = config.home.git.signing.key;
      signByDefault = true;
    };
  };
}
