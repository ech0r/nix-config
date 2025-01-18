{ config, pkgs, lib, ... }:

{
  # Import the hardware configuration dynamically
  # Basic system settings
  networking.hostName = "nuc"; # Hostname for your NUC
  time.timeZone = "America/Los_Angeles"; # Adjust to your timezone

  # Boot settings
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Users
  users.users.john = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Add user to sudo group
    openssh.authorizedKeys.keyFiles = [ 
      "../../shared/authorized_keys"
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

  # Optional: Home-Manager (if you're using it)
  # programs.home-manager.enable = true;

  # Logging
  systemd.services.journal-gatewayd.enable = true; # Optional for remote log viewing

}
