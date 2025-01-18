{ config, pkgs, lib, ... }:

{
  # Import the hardware configuration dynamically
  import = [
    /mnt/etc/nixos/hardware-configuration.nix
  ];
  # Basic system settings
  networking.hostName = "nuc"; # Hostname for your NUC
  time.timeZone = "America/Los_Angeles"; # Adjust to your timezone

  #nix settings
  nix.settings.experimental-features = ["nix-command" "flakes"];



  # Boot settings
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFileSystems = ["zfs"];
  
  boot.zfs.extraPools = ["storage"];

  services.zfs = {
    enable = true;
    autoMount = true;
  };

  # Users
  users.users.john = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Add user to sudo group
    openssh.authorizedKeys.keyFiles = [ 
      ../../shared/authorized_keys
    ];
  };

  # Networking
  networking.networkmanager.enable = true; # Use NetworkManager
  networking.firewall.allowedTCPPorts = [ 22 ]; # Allow SSH
  networking.firewall.enable = true;

  # Services
  services.openssh.enable = true; # Enable SSH
  services.avahi = {
    enable = true; # Enable Avahi for network discovery
    nssmdns = true;
  };

  # System Updates
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = false; # Change to true if you want auto-reboot after updates

  # Power Management
  powerManagement.cpuFreqGovernor = "powersave"; # Energy-efficient CPU governor

  # Software
  environment.systemPackages = with pkgs; [
    vim
    git
    htop
    tmux
  ];

  services.jellyfin = {
    enable = true;
    dataDir = "/storage/jellyfin/data";
    bindAddress = "0.0.0.0";
  };
  networking.firewall.allowedTCPParts = [ 8096 8920 ];

  # Optional: Home-Manager (if you're using it)
  # programs.home-manager.enable = true;

  # Logging
  systemd.services.journal-gatewayd.enable = true; # Optional for remote log viewing

}
