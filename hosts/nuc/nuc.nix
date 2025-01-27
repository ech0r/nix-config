{ config, pkgs, lib, ... }:

{
  
  # Import the hardware configuration dynamically
  imports = [
    ./hardware-configuration.nix
  ];
  
  # Basic system settings
  time.timeZone = "America/Los_Angeles"; # Adjust to your timezone

  #nix settings
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Boot settings
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ==== STORAGE ====
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.zfs.extraPools = [ "storage" ];
  services.zfs.autoScrub.enable = true;
  
  # Users
  users.users.root = {
    hashedPassword = ''$6$aKizz2yq02x5K0QA$xVGMp4iprpgTBZ58oa73oHi4pan4GlVgZhJZMpROZ0cUKPA2wZBrQ0ZccvlSAL2huyrHH98PyHY4zaDYMcQg70'';
  };

  users.users.john = {
    isNormalUser = true;
    hashedPassword = ''$6$IWzN/g2rPyMKpb/b$k9sXeq.YutOps0DxISkXSiUCZHhdffoNxsN4hHFlMqzxZ84RUiXrmNh22dHsiaZiEcuoGtH7ekQyrgV/a3I.I0'';
    extraGroups = [ "wheel" "docker" ]; # Add user to sudo group
    openssh.authorizedKeys.keyFiles = [ 
      ../../shared/authorized_keys
    ];
  };

  nix.settings.trusted-users = [ "@wheel" ];

  # Networking
  networking = {
    defaultGateway = "192.168.1.1";
    nameservers = [
      "192.168.1.5"
    ];
    hostName = "nuc";
    hostId = "28133081";
    interfaces.enp0s31f6 = {
      ipv4.addresses = [{
        address = "192.168.1.8";
        prefixLength = 24;
      }];
    };
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 9420 ];
    };
  };
  # ==== VIRTUALIZATION ====
    virtualisation.docker.enable = true;

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
    docker
    docker-compose
    git
    htop
    jellyfin
    jellyfin-ffmpeg
    jellyfin-web
    tmux
    vim
  ];

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  # Optional: Home-Manager (if you're using it)
  # programs.home-manager.enable = true;

  # Logging
  systemd.services.journal-gatewayd.enable = true; # Optional for remote log viewing

}
