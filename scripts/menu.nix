# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

{ pkgs ? import <nixpkgs> { } }:

let
  name = "nixconf-menu";
  script = pkgs.writeShellScriptBin name ''
    #!/usr/bin/env bash
    set -e

    # Colors
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
    BOLD='\033[1m'

    # Clear screen function
    clear_screen() {
      printf "\033c"
    }

    # Print header
    print_header() {
      echo -e "''${BLUE}''${BOLD}NixOS Configuration Manager''${NC}"
      echo -e "''${BLUE}========================''${NC}\n"
    }

    # Get current host information
    get_host_info() {
      echo -e "''${BOLD}Current Host:''${NC} $(hostname)"
      echo -e "''${BOLD}Available Hosts:''${NC}"
      for host in hosts/*/; do
        if [ -d "$host" ] && [ "$host" != "hosts/template/" ]; then
          host_name=$(basename "$host")
          if [ "$host_name" = "$(hostname)" ]; then
            echo -e "  - ''${GREEN}$host_name''${NC} (current)"
          else
            echo -e "  - $host_name"
          fi
        fi
      done
      echo
    }

    # Get current user information
    get_user_info() {
      echo -e "''${BOLD}Current User:''${NC} $USER"
      echo -e "''${BOLD}Configured Users:''${NC}"
      for user in homes/*/; do
        if [ -d "$user" ]; then
          user_name=$(basename "$user")
          if [ "$user_name" = "$USER" ]; then
            echo -e "  - ''${GREEN}$user_name''${NC} (current)"
          else
            echo -e "  - $user_name"
          fi
        fi
      done
      echo
    }

    # Print menu
    print_menu() {
      get_host_info
      get_user_info
      echo -e "''${BOLD}Available Options:''${NC}\n"
      echo "1) Manage Hosts"
      echo "2) Manage Users"
      echo "q) Quit"
      echo
      read -p "Select an option: " choice
      echo
      case $choice in
        1) host_menu ;;
        2) user_menu ;;
        q) exit 0 ;;
        *) 
          echo -e "''${RED}Invalid option''${NC}"
          sleep 1
          main_menu
          ;;
      esac
    }

    # Host management menu
    host_menu() {
      clear_screen
      print_header
      get_host_info
      echo -e "''${BOLD}Host Management''${NC}\n"
      echo "1) Create new host"
      echo "2) Install host"
      echo "3) Configure host"
      echo "4) Stage host for installation"
      echo "b) Back to main menu"
      echo "q) Quit"
      echo
      read -p "Select an option: " choice
      echo
      case $choice in
        1)
          read -p "Enter hostname: " hostname
          manage-host create "$hostname"
          read -p "Press Enter to continue..."
          host_menu
          ;;
        2)
          read -p "Enter hostname to install: " hostname
          if [ -d "hosts/$hostname" ]; then
            manage-host install "$hostname"
          else
            echo -e "''${RED}Host $hostname does not exist''${NC}"
            sleep 1
          fi
          read -p "Press Enter to continue..."
          host_menu
          ;;
        3)
          read -p "Enter hostname to configure: " hostname
          if [ -d "hosts/$hostname" ]; then
            $EDITOR "hosts/$hostname/default.nix"
          else
            echo -e "''${RED}Host $hostname does not exist''${NC}"
            sleep 1
          fi
          host_menu
          ;;
        4)
          read -p "Enter hostname to stage: " hostname
          if [ -d "hosts/$hostname" ]; then
            echo "Staging $hostname for installation..."
            nixos-rebuild build --flake ".#$hostname"
            echo "Host $hostname has been staged for installation"
            read -p "Press Enter to continue..."
          else
            echo -e "''${RED}Host $hostname does not exist''${NC}"
            sleep 1
          fi
          host_menu
          ;;
        b) main_menu ;;
        q) exit 0 ;;
        *)
          echo -e "''${RED}Invalid option''${NC}"
          sleep 1
          host_menu
          ;;
      esac
    }

    # User management menu
    user_menu() {
      clear_screen
      print_header
      get_user_info
      echo -e "''${BOLD}User Management''${NC}\n"
      echo "1) Create new user"
      echo "2) Switch user configuration"
      echo "3) Configure user"
      echo "b) Back to main menu"
      echo "q) Quit"
      echo
      read -p "Select an option: " choice
      echo
      case $choice in
        1)
          read -p "Enter username: " username
          manage-user create "$username"
          read -p "Press Enter to continue..."
          user_menu
          ;;
        2)
          read -p "Enter username to switch to: " username
          if [ -d "homes/$username" ]; then
            manage-user switch "$username"
          else
            echo -e "''${RED}User $username does not exist''${NC}"
            sleep 1
          fi
          read -p "Press Enter to continue..."
          user_menu
          ;;
        3)
          read -p "Enter username to configure: " username
          if [ -d "homes/$username" ]; then
            $EDITOR "homes/$username/default.nix"
          else
            echo -e "''${RED}User $username does not exist''${NC}"
            sleep 1
          fi
          user_menu
          ;;
        b) main_menu ;;
        q) exit 0 ;;
        *)
          echo -e "''${RED}Invalid option''${NC}"
          sleep 1
          user_menu
          ;;
      esac
    }

    # Main menu function
    main_menu() {
      clear_screen
      print_header
      print_menu
    }

    # Start the menu
    main_menu
  '';
in pkgs.symlinkJoin {
  inherit name;
  paths = [ script ];
  buildInputs = [ pkgs.makeWrapper ];
  postBuild = "wrapProgram $out/bin/${name} --prefix PATH : ${pkgs.lib.makeBinPath [
    pkgs.coreutils
    pkgs.bash
    (import ./manage-host.nix { inherit pkgs; })
    (import ./manage-user.nix { inherit pkgs; })
  ]}";
}
