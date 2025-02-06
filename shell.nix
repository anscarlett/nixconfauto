# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = [
    (import ./scripts/manage-host.nix { inherit pkgs; })
    (import ./scripts/manage-user.nix { inherit pkgs; })
    (import ./scripts/menu.nix { inherit pkgs; })
  ];

  # Auto-start the menu when entering the shell
  shellHook = ''
    nixconf-menu
  '';
}
