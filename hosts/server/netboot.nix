{ config, pkgs, lib, ... }:

{
  boot.initrd.network = {
    enable = true;
  };

  networking.hostName = "nixos-netboot-installer";

  environment.systemPackages = with pkgs; [
    neovim
  ];

  boot.kernelParams = ["console-tty0" "console=ttyS0" ];

  services.xserver.enable = false;

}
