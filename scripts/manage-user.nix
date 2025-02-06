# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

{ pkgs ? import <nixpkgs> { } }:

let
  name = "manage-user";
  script = pkgs.writeShellScriptBin name ''
    set -e

    function print_usage() {
      echo "Usage: $0 <command> [options]"
      echo ""
      echo "Commands:"
      echo "  create <username>    Create a new user configuration"
      echo "  switch <username>    Switch to a user's configuration"
      echo ""
      echo "Examples:"
      echo "  $0 create john"
      echo "  $0 switch john"
    }

    function create_user() {
      local username=$1
      if [ -z "$username" ]; then
        echo "Error: Username is required"
        print_usage
        exit 1
      fi

      local user_dir="homes/$username"
      if [ -d "$user_dir" ]; then
        echo "Error: User $username already exists"
        exit 1
      fi

      echo "Creating new user: $username"
      mkdir -p "$user_dir"
      
      # Create default.nix for the user
      cat > "$user_dir/default.nix" << EOF
# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "$username";
  home.homeDirectory = "/home/$username";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  home.stateVersion = "23.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Packages to install
  home.packages = with pkgs; [
    # Add your packages here
  ];

  # Program configurations
  programs = {
    git = {
      enable = true;
      userName = "$username";
      userEmail = "$username@users.noreply.github.com";
    };
  };
}
EOF

      echo "User $username created successfully!"
      echo "Next steps:"
      echo "1. Edit $user_dir/default.nix to customize your configuration"
      echo "2. Run '$0 switch $username' to activate the configuration"
    }

    function switch_user() {
      local username=$1
      if [ -z "$username" ]; then
        echo "Error: Username is required"
        print_usage
        exit 1
      fi

      local user_dir="homes/$username"
      if [ ! -d "$user_dir" ]; then
        echo "Error: User $username does not exist"
        exit 1
      }

      echo "Switching to user configuration: $username"
      home-manager switch --flake ".#$username@$HOSTNAME"
    }

    case "$1" in
      "create")
        create_user "$2"
        ;;
      "switch")
        switch_user "$2"
        ;;
      *)
        print_usage
        exit 1
        ;;
    esac
  '';
in pkgs.symlinkJoin {
  inherit name;
  paths = [ script ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = "wrapProgram $out/bin/${name} --prefix PATH : ${pkgs.lib.makeBinPath [
    pkgs.coreutils
    pkgs.home-manager
  ]}";
}
