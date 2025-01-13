{ config, pkgs, lib, ... }:

{
  # Set up minimal networking
  networking.hostName = "pxe-install-server";

  # Enable LVM and automatic partitioning
  boot.initrd.lvm.enable = true;

  # LVM configuration
  system.activationScripts.partitionAndLVM = lib.mkAfter ''
    echo "Setting up LVM partitions..."
    for disk in $(lsblk -d -o NAME -n | grep -E "^sd|^nvme|^vd"); do
      parted /dev/$disk --script -- mklabel gpt mkpart primary 1MiB 100%
      pvcreate /dev/${disk}1
      vgextend vg-root /dev/${disk}1 || vgcreate vg-root /dev/${disk}1
    done
    lvcreate -l 100%FREE -n root vg-root
  '';

  # Auto-run nixos-install with your GitHub flake
  system.activationScripts.installFromFlake = lib.mkAfter ''
    echo "Installing NixOS from flake..."
    nixos-install --flake github:yourusername/your-repo#server --no-root-passwd --replace-bootloader
    poweroff
  '';

  boot.tmpOnTmpfs = true;
  environment.systemPackages = with pkgs; [
    lvm2
    parted
  ];
}
