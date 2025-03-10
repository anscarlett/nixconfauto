# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

{ pkgs ? import <nixpkgs> { } }:

let
  name = "nixconf-menu";
  script = pkgs.writeShellScriptBin name ''
    # Simple menu handler
    handle_menu() {
      local prompt=$1
      local choice
      echo "$prompt"
      read choice
      echo $choice
    }

    #!/usr/bin/env bash
    set -e

    # Colors
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    NC='\033[0m' # No Color
    BOLD='\033[1m'

    # Trap ctrl-c and call cleanup
    trap cleanup INT

    cleanup() {
      echo -e "\n\nExiting..."
      exit 0
    }

    # Read input with timeout
    read_input() {
      read -t 1 -p "$1" choice
      echo "$choice"
    }

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
      for category in hosts/*/; do
        if [ -d "$category" ] && [ "$category" != "hosts/template/" ]; then
          category_name=$(basename "$category")
          echo -e "''${BOLD}$category_name:''${NC}"
          for host in "$category"*/; do
            if [ -d "$host" ]; then
              host_name=$(basename "$host")
              if [ "$host_name" = "$(hostname)" ]; then
                echo -e "  - ''${GREEN}$host_name''${NC} (current)"
              else
                echo -e "  - $host_name"
              fi
            fi
          done
        fi
      done
      echo
    }

    # Get current user information
    get_user_info() {
      echo -e "''${BOLD}Current User:''${NC} $USER"
      echo -e "''${BOLD}Configured Users:''${NC}"
      for category in homes/*/; do
        if [ -d "$category" ] && [ "$category" != "homes/template/" ]; then
          category_name=$(basename "$category")
          echo -e "''${BOLD}$category_name:''${NC}"
          for user in "$category"*/; do
            if [ -d "$user" ]; then
              user_name=$(basename "$user")
              if [ "$user_name" = "$USER" ]; then
                echo -e "  - ''${GREEN}$user_name''${NC} (current)"
              else
                echo -e "  - $user_name"
              fi
            fi
          done
        fi
      done
      echo
    }



    # Host management menu
    host_menu() {
      while true; do
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
          echo -e "''${BOLD}Available categories:''${NC}"
          for category in hosts/*/; do
            if [ -d "$category" ] && [ "$category" != "hosts/template/" ]; then
              echo "  - $(basename "$category")"
            fi
          done
          echo
          read -p "Enter category (home/work): " category
          if [ ! -d "hosts/$category" ] || [ "$category" = "template" ]; then
            echo -e "''${RED}Invalid category''${NC}"
            sleep 1
            continue
          fi
          read -p "Enter hostname: " hostname
          manage-host create "$category/$hostname"
          read -p "Press Enter to continue..."
          ;;
        2)
          read -p "Enter category (home/work): " category
          if [ ! -d "hosts/$category" ] || [ "$category" = "template" ]; then
            echo -e "''${RED}Invalid category''${NC}"
            sleep 1
            continue
          fi
          read -p "Enter hostname: " hostname
          if [ -d "hosts/$category/$hostname" ]; then
            manage-host install "$category/$hostname"
          else
            echo -e "''${RED}Host $hostname does not exist in $category''${NC}"
            sleep 1
          fi
          read -p "Press Enter to continue..."
          ;;
        3)
          read -p "Enter category (home/work): " category
          if [ ! -d "hosts/$category" ] || [ "$category" = "template" ]; then
            echo -e "''${RED}Invalid category''${NC}"
            sleep 1
            continue
          fi
          read -p "Enter hostname: " hostname
          if [ -d "hosts/$category/$hostname" ]; then
            $EDITOR "hosts/$category/$hostname/default.nix"
          else
            echo -e "''${RED}Host $hostname does not exist in $category''${NC}"
            sleep 1
          fi
          ;;
        4)
          read -p "Enter category (home/work): " category
          if [ ! -d "hosts/$category" ] || [ "$category" = "template" ]; then
            echo -e "''${RED}Invalid category''${NC}"
            sleep 1
            continue
          fi
          read -p "Enter hostname: " hostname
          if [ -d "hosts/$category/$hostname" ]; then
            echo "Staging $hostname for installation..."
            nixos-rebuild build --flake ".#$category-$hostname"
            echo "Host $hostname has been staged for installation"
            read -p "Press Enter to continue..."
          else
            echo -e "''${RED}Host $hostname does not exist in $category''${NC}"
            sleep 1
          fi
          ;;
        b)
          break
          ;;
        q)
          exit 0
          ;;
        *)
          echo -e "''${RED}Invalid option''${NC}"
          sleep 1
          ;;
      esac
      done
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
          echo -e "''${BOLD}Available categories:''${NC}"
          for category in homes/*/; do
            if [ -d "$category" ] && [ "$category" != "homes/template/" ]; then
              echo "  - $(basename "$category")"
            fi
          done
          echo
          read -p "Enter category (home/work): " category
          if [ ! -d "homes/$category" ] || [ "$category" = "template" ]; then
            echo -e "''${RED}Invalid category''${NC}"
            sleep 1
            user_menu
            return
          fi
          read -p "Enter username: " username
          manage-user create "$category/$username"
          read -p "Press Enter to continue..."
          user_menu
          ;;
        2)
          read -p "Enter category (home/work): " category
          if [ ! -d "homes/$category" ] || [ "$category" = "template" ]; then
            echo -e "''${RED}Invalid category''${NC}"
            sleep 1
            user_menu
            return
          fi
          read -p "Enter username: " username
          if [ -d "homes/$category/$username" ]; then
            manage-user switch "$category/$username"
          else
            echo -e "''${RED}User $username does not exist in $category''${NC}"
            sleep 1
          fi
          read -p "Press Enter to continue..."
          user_menu
          ;;
        3)
          read -p "Enter category (home/work): " category
          if [ ! -d "homes/$category" ] || [ "$category" = "template" ]; then
            echo -e "''${RED}Invalid category''${NC}"
            sleep 1
            user_menu
            return
          fi
          read -p "Enter username: " username
          if [ -d "homes/$category/$username" ]; then
            $EDITOR "homes/$category/$username/default.nix"
          else
            echo -e "''${RED}User $username does not exist in $category''${NC}"
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
      while true; do
        clear_screen
        print_header
        get_host_info
        get_user_info
        echo -e "Available Options:\n"
        echo "1) Manage Hosts"
        echo "2) Manage Users"
        echo "q) Quit"
        echo
        read -r choice
        case $choice in
          1)
            host_menu
            ;;
          2)
            user_menu
            ;;
          q)
            exit 0
            ;;
          *)
            echo -e "''${RED}Invalid option''${NC}"
            sleep 1
            ;;
        esac
      done
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
