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

    # Print menu
    print_menu() {
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
      echo -e "''${BOLD}Host Management''${NC}\n"
      echo "1) Create new host"
      echo "2) Install host"
      echo "3) List existing hosts"
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
          # Show available hosts
          echo -e "''${BOLD}Available hosts:''${NC}"
          for host in hosts/*/; do
            if [ -d "$host" ] && [ "$host" != "hosts/template/" ]; then
              echo "  - $(basename "$host")"
            fi
          done
          echo
          read -p "Enter hostname to install: " hostname
          manage-host install "$hostname"
          read -p "Press Enter to continue..."
          host_menu
          ;;
        3)
          echo -e "''${BOLD}Existing hosts:''${NC}"
          for host in hosts/*/; do
            if [ -d "$host" ] && [ "$host" != "hosts/template/" ]; then
              echo "  - $(basename "$host")"
            fi
          done
          echo
          read -p "Press Enter to continue..."
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
      echo -e "''${BOLD}User Management''${NC}\n"
      echo "1) Create new user"
      echo "2) Switch user configuration"
      echo "3) List existing users"
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
          # Show available users
          echo -e "''${BOLD}Available users:''${NC}"
          for user in homes/*/; do
            if [ -d "$user" ]; then
              echo "  - $(basename "$user")"
            fi
          done
          echo
          read -p "Enter username to switch to: " username
          manage-user switch "$username"
          read -p "Press Enter to continue..."
          user_menu
          ;;
        3)
          echo -e "''${BOLD}Existing users:''${NC}"
          for user in homes/*/; do
            if [ -d "$user" ]; then
              echo "  - $(basename "$user")"
            fi
          done
          echo
          read -p "Press Enter to continue..."
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
