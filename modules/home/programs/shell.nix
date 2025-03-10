# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Shell configuration
{ config, pkgs, lib, ... }: {
  options.home.shell = {
    aliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        ll = "ls -la";
        ".." = "cd ..";
        "..." = "cd ../..";
        g = "git";
        k = "kubectl";
        d = "docker";
      };
      description = "Common shell aliases to use across all shells";
      example = {
        ll = "ls -la";
        ".." = "cd ..";
      };
    };
  };

  # Bash configuration
  programs.bash = {
    enable = config.defaultPrograms.shell == "bash" || config.programs.bash.enable;
    enableCompletion = true;
    # Starship prompt
    initExtra = ''
      eval "$(starship init bash)"
    '';
    # Useful aliases
    shellAliases = config.home.shell.aliases;
  };

  # Fish configuration
  programs.fish = {
    enable = config.defaultPrograms.shell == "fish" || config.programs.fish.enable;
    # Starship prompt
    interactiveShellInit = ''
      starship init fish | source
    '';
    # Useful aliases
    shellAliases = config.home.shell.aliases;
  };

  # Zsh configuration
  programs.zsh = {
    enable = config.defaultPrograms.shell == "zsh" || config.programs.zsh.enable;
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
    shellAliases = config.home.shell.aliases;
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
