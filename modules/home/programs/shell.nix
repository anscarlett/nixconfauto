# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Shell configuration (using zsh)
{ config, pkgs, lib, ... }: {
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    # Starship prompt
    initExtra = ''
      eval "$(starship init zsh)"
    '';

    # Oh My Zsh
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "kubectl"
        "history"
        "sudo"
      ];
    };

    # Useful aliases
    shellAliases = {
      ll = "ls -la";
      ".." = "cd ..";
      "..." = "cd ../..";
      g = "git";
      k = "kubectl";
      d = "docker";
    };
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      git_branch.symbol = " ";
      package.disabled = true;
    };
  };

  # Direnv for project-specific environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
