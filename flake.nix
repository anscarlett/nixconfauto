# SPDX-FileCopyrightText: 2025 Adrian Scarlett
#
# SPDX-License-Identifier: GPL-3.0-only

{
  description = "NixOS configuration";
  inputs = import ./inputs;
  outputs = inputs: import ./outputs inputs;
}
