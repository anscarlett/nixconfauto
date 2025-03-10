# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

# Editor configuration
{ config, pkgs, lib, ... }: {
  # Neovim configuration
  programs.neovim = {
    enable = config.defaultPrograms.editor == "neovim" || config.programs.neovim.enable;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    
    # Plugins can be added here
    plugins = with pkgs.vimPlugins; [
      # LSP
      nvim-lspconfig
      # Completion
      nvim-cmp
      # Syntax
      vim-nix
      # Git integration
      vim-fugitive
      # File explorer
      nvim-tree-lua
      # Theme
      tokyonight-nvim
    ];
  };

  # VS Code configuration
  programs.vscode = {
    enable = config.defaultPrograms.editor == "vscode" || config.programs.vscode.enable;
    package = pkgs.vscodium; # Use VSCodium instead of VS Code
    extensions = with pkgs.vscode-extensions; [
      # Add your desired VS Code extensions here
      # Example:
      # ms-python.python
      # rust-lang.rust-analyzer
      jnoortheen.nix-ide
    ];
    userSettings = {
      "editor.fontFamily" = config.stylix.fonts.monospace.name;
      "editor.fontSize" = 14;
      "editor.lineNumbers" = "relative";
      "editor.renderWhitespace" = "boundary";
      "editor.rulers" = [ 80 120 ];
      "files.autoSave" = "onFocusChange";
      "workbench.colorTheme" = "Default Dark+";
    };
  };

  # Emacs configuration
  programs.emacs = {
    enable = config.defaultPrograms.editor == "emacs" || config.programs.emacs.enable;
    package = pkgs.emacs;
    extraPackages = epkgs: with epkgs; [
      # Add your desired Emacs packages here
      use-package
      evil          # Vim keybindings
      magit         # Git integration
      projectile    # Project management
      company       # Completion
      flycheck      # Syntax checking
      nix-mode      # Nix support
    ];
  };

  # Common editor dependencies
  home.packages = with pkgs; [
    # Language servers
    nil             # Nix
    pyright         # Python
    rust-analyzer   # Rust
    # Tools
    ripgrep         # Fast search
    fd              # Fast find
    tree-sitter     # Parsing
  ];
}
