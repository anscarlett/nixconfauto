# Advanced disk configuration with LUKS, BTRFS, and impermanence
{ lib, ... }: {
  # Function to create an advanced disk config
  mkDisk = { 
    device,
    encryptionType ? "password", # "password" or "yubikey"
    keyFile ? null,             # Path to key file for yubikey
    hostname ? "nixos",         # Used for LUKS label
  }: {
    disk = {
      main = {
        type = "disk";
        device = "/dev/${device}";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "${hostname}-luks";
                # If using yubikey, we need a keyfile
                extraOpenArgs = lib.optionals (encryptionType == "yubikey" && keyFile != null) [
                  "--key-file=${keyFile}"
                ];
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ]; # Force format
                  subvolumes = {
                    # No mountpoint for root - it's read-only
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [ "ro" "compress=zstd" "noatime" ];
                    };
                    # Persistent data
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/persist" = {
                      mountpoint = "/persist";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    # State directories that need to be writable
                    "/state" = {
                      mountpoint = "/state";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    # Temporary directories
                    "/tmp" = {
                      mountpoint = "/tmp";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    # Home directories
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
