{ config, pkgs, lib, ... }:

{
  
  # Import the hardware configuration dynamically
  imports = [
    /mnt/etc/nixos/hardware-configuration.nix
  ];
  
  # Basic system settings
  time.timeZone = "America/Los_Angeles"; # Adjust to your timezone

  #nix settings
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Boot settings
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.supportedFilesystems = [ "zfs" ];
  
  fileSystems."/storage" = {
    device = "storage";
    fsType = "zfs";
  };

  boot.zfs.forceImportRoot = false;
  boot.zfs.extraPools = ["storage"];

  # Users
  users.users.root = {
    hashedPassword = "$6$aKizz2yq02x5K0QA$xVGMp4iprpgTBZ58oa73oHi4pan4GlVgZhJZMpROZ0cUKPA2wZBrQ0ZccvlSAL2huyrHH98PyHY4zaDYMcQg70";
  };

  users.users.john = {
    isNormalUser = true;
    hashedPassword = "$6$w30qlt2dFpBntIJe$LAnC1/YATMLCX2prohxVvvXS9VxvZJqjXN1uJlts.6FcTS3ac42QdTcbUijbtyM/lZrGXEZXWeSU8WREhYYkQ1";
    extraGroups = [ "wheel" ]; # Add user to sudo group
    openssh.authorizedKeys.keyFiles = [ 
      ../../shared/authorized_keys
    ];
  };

  # Networking
  networking.hostName = "nuc"; # Hostname for your NUC
  networking.hostId = "28133081";
  networking.networkmanager.enable = true; # Use NetworkManager
  networking.firewall.allowedTCPPorts = [ 22 ];
  networking.firewall.enable = true;

  # Services
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
  };

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
    dataDir = /var/lib/jellyfin/conf;
    configDir = /var/lib/jellyfin/data;
    openFirewall = true;
  };

  system.activationScripts.migrateJellyfinToZFS = {
    text = ''
      if [-d /storage/jellyfin ]; then
        chown -R jellyfin:jellyfin /storage/jellyfin
        rm -rf /var/lib/jellyfin/*
        ln -s /storage/jellyfin/config /var/lib/jellyfin/conf 
        ln -s /storage/jellyfin/data /var/lib/jellyfin/data
      fi
    '';
  };

  # Optional: Home-Manager (if you're using it)
  # programs.home-manager.enable = true;

  # Logging
  systemd.services.journal-gatewayd.enable = true; # Optional for remote log viewing

}
