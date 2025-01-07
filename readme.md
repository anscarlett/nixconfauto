# Nixos Configuration

## configs

## homes

## hosts
the initial two files in the hosts directory are:
- configuration.nix
- hardware-configuration.nix
these two files are modified forms of the ones created by the nixos-generate-config tool.

The menu system will present the user with a list of hosts to select from, or to create a new host.
If a new host is selected, the options will be presented to the user to configure the host. Initially, the options will be:
- hostname
- disko config selection

the following options will default to uk
- timezone
- locale

## scripts
### menu
a set of scripts to initialise a host or select a predefined host.

## utils
basic utils