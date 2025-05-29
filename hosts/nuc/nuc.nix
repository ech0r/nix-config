{ config, pkgs, lib, nixvim, ... }:
let
  # Reference the nvim package from the nixvim flake
  nvim = nixvim.packages.x86_64-linux.default;
in

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
  boot = {
    loader =  {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ 
      "ipv6.disable=1" 
      "usbcore.autosuspend=-1"
      "usb_storage"
    ];
    extraModprobeConfig = ''
      options usb-storage delay_use=1
    '';
    # ==== STORAGE ====
    supportedFilesystems = [ "zfs" ];
    zfs = {
      forceImportRoot = false;
      extraPools = [ "storage" ];
    };
  };
  services.zfs = {
    autoScrub.enable = true;
    autoScrub.interval = "quarterly";
  };


  # ==== Cron ====
  services.cron = 
  let 
    disk-keep-alive = ./. + "/disk-keep-alive.sh"; 
    in {
      enable = true;
      systemCronJobs = [ 
        "@reboot root ${disk-keep-alive}"
      ];
    };

  # ==== Virtualization ====
    virtualisation.libvirtd.enable = true;
  
  # ==== Users and Groups ====
  # Create storage group
  users.groups = {
    storage = {
      gid = 500;
    };
  };

  users.users.root = {
    hashedPassword = ''$6$aKizz2yq02x5K0QA$xVGMp4iprpgTBZ58oa73oHi4pan4GlVgZhJZMpROZ0cUKPA2wZBrQ0ZccvlSAL2huyrHH98PyHY4zaDYMcQg70'';
    openssh.authorizedKeys.keyFiles = [ 
      ../../shared/authorized_keys
    ];
  };

  users.users.john = {
    isNormalUser = true;
    hashedPassword = ''$6$IWzN/g2rPyMKpb/b$k9sXeq.YutOps0DxISkXSiUCZHhdffoNxsN4hHFlMqzxZ84RUiXrmNh22dHsiaZiEcuoGtH7ekQyrgV/a3I.I0'';
    extraGroups = [ "wheel" "docker" "storage" ]; # Add user to sudo group
    openssh.authorizedKeys.keyFiles = [ 
      ../../shared/authorized_keys
    ];
  };

  nix.settings.trusted-users = [ "@wheel" ];

  # ============ Networking =============
  networking = {
    defaultGateway = "192.168.1.1";
    nameservers = [
      "192.168.1.5"
      "1.1.1.1"
    ];
    hostName = "nuc";
    hostId = "28133081";
    enableIPv6 = false;
    useDHCP = false;
    networkmanager.enable = false;
    interfaces.enp0s31f6 = {
      ipv4.addresses = [{
        address = "192.168.1.8";
        prefixLength = 24;
      }];
    };
    firewall = {
      enable = true; 
      allowedTCPPorts = [ 22 2049 6080 5900 9420 ];
      # allowedUDPPortRanges = [
      #   {
      #     from = 49152;
      #     to = 65525;
      #   }
      # ];
    };
  };

  # ============ virtualisation ===============
    virtualisation.docker.enable = true;

  # =============== Services ==================

  services.udev.extraRules = ''
    # Disable USB suspend on all storage devices
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
  '';


  services.nfs.server = {
    enable = true;
    exports = ''
      /storage/jellyfin/downloads 10.0.2.15(rw,no_subtree_check,fsid=0,no_root_squash,insecure) 192.168.1.0/24(rw,no_subtree_check,fsid=0,no_root_squash,insecure)
    '';
  };

  services.tailscale = {
    enable = true;
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts."nuc.tail54b865.ts.net" = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:6080";
        proxyWebsockets = true;
      };
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
    };
  };

  services.avahi = {
    enable = true; # Enable Avahi for network discovery
    nssmdns4 = true;
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
    nvim
    qemu
    # rocm-opencl-runtime
    clinfo
  ];

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  # Optional: Home-Manager (if you're using it)
  # programs.home-manager.enable = true;
  systemd.services.start-vm = {
    description = "Start NixOS VM in homedir";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "john";
      WorkingDirectory = "/home/john/vm";
      ExecStart = "/home/john/vm/result/bin/run-nixos-vm-vm";
      Restart = "always";
    };
  };

  # Logging
  systemd.services.journal-gatewayd.enable = true; # Optional for remote log viewing
  system.stateVersion = "25.05"; 

}
