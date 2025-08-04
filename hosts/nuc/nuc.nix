{ config, pkgs, lib, nixvim, ... }:
let
  # Reference the nvim package from the nixvim flake
  nvim = nixvim.packages.x86_64-linux.default;
in

{
  # Import the hardware configuration dynamically
  imports = [
    ../../shared/home-manager/home-manager.nix
    ./hardware-configuration.nix
  ];
  
  # Basic system settings
  time.timeZone = "America/Los_Angeles"; # Adjust to your timezone

  #nix settings
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # ==== UNFREE PACKAGES ====
  nixpkgs.config.allowUnfree = true;

  # ==== BOOT SETTINGS ====
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
  };

  # ==== ZFS ====
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs = {
    forceImportRoot = false;
    extraPools = [ "storage" ];
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

  # ==== Swapfile ====
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 16*1024;
  }];

  # ==== Virtualization ====
  virtualisation.libvirtd.enable = true;

  # ==== Users and Groups ====
  users = { 
    groups = {
      storage = {
        gid = 500;
      };
    };
    users = { 
      root = {
        hashedPassword = ''$6$aKizz2yq02x5K0QA$xVGMp4iprpgTBZ58oa73oHi4pan4GlVgZhJZMpROZ0cUKPA2wZBrQ0ZccvlSAL2huyrHH98PyHY4zaDYMcQg70'';
        openssh.authorizedKeys.keyFiles = [ 
          ../../shared/authorized_keys
        ];
      };
      john = {
        isNormalUser = true;
        hashedPassword = ''$6$IWzN/g2rPyMKpb/b$k9sXeq.YutOps0DxISkXSiUCZHhdffoNxsN4hHFlMqzxZ84RUiXrmNh22dHsiaZiEcuoGtH7ekQyrgV/a3I.I0'';
        extraGroups = [ "wheel" "docker" "storage" ]; # Add user to sudo group
        openssh.authorizedKeys.keyFiles = [ 
          ../../shared/authorized_keys
        ];
      };
      jellyfin = {
        isSystemUser = true;
        uid = 997;
      };
    };
  };
  nix.settings.trusted-users = [ "@wheel" ];

  # ===== NETWORKING =====
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
      allowedTCPPorts = [ 
        22    # ssh
        80    # http
        2049  # nfs
        111   # nfs
        20048 # nfs
        32765 # nfs
        32768 # nfs
        6080  # vnc/vm
        5900  # vnc/vm 
        9420 
      ];
    };
  };

  # ==== OTHER SERVICES =====
  services.udev.extraRules = ''
    # Disable USB suspend on all storage devices
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="on"
  '';

  # ==== NFS ====
  services.nfs.server = {
    enable = true;
    mountdPort = 20048;
    statdPort = 32765;
    lockdPort = 32768;
    exports = ''
      /storage/jellyfin 192.168.1.0/24(rw,no_subtree_check,fsid=0,no_root_squash,insecure)
      /storage/photos 192.168.1.0/24(rw,no_subtree_check,fsid=0,no_root_squash,insecure)
    '';
  };

  services.tailscale = {
    enable = true;
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    virtualHosts."nuc.lan" = {
      locations."/vm" = {
        extraConfig = ''
          return 302 /vm/; 
        '';
      };
      locations."/vm/" = {
        extraConfig = ''
          proxy_pass http://127.0.0.1:6080/;
          proxy_http_version 1.1;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";
        '';
      };
      locations."/jellyfin" = {
        extraConfig = ''
          proxy_pass http://127.0.0.1:8096;
          proxy_http_version 1.1;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;

          # Fix for WebSocket support
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection "upgrade";

          # Rewrite base path
          proxy_redirect off;
          sub_filter_once off;
          sub_filter 'href="/' 'href="/jellyfin/';
          sub_filter 'src="/' 'src="/jellyfin/';
        '';
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
    git
    htop
    jellyfin
    jellyfin-ffmpeg
    jellyfin-web
    inotify-tools
    tmux
    vim
    nvim
    qemu
    clinfo
  ];

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  # programs.home-manager.enable = true;
  systemd = {
    services = {
      enforce-jellyfin-downloads = {
        description = "Fix Jellyfin Downloads Permissions";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        serviceConfig = {
          Type = "simple";
          Restart = "always";
          ExecStart = pkgs.writeShellScript "fix-downloads.sh" ''
            WATCH_DIR="/storage/jellyfin/downloads/incomplete"
            OWNER="jellyfin"
            GROUP="storage"
            PERMS="0775"

            # Initial fix
            chown -R "$OWNER:$GROUP" "$WATCH_DIR"
            find "$WATCH_DIR" -type d -exec chmod "$PERMS" {} +
            find "$WATCH_DIR" -type f -exec chmod "$PERMS" {} +

            # Watch and fix
            ${pkgs.inotify-tools}/bin/inotifywait -mrq -e create -e moved_to -e attrib --format "%w%f" "$WATCH_DIR" | while read path; do
              chown "$OWNER:$GROUP" "$path"
              chmod "$PERMS" "$path"
            done
          '';
          User = "root";
        };
      };
      vm = {
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
      journal-gatewayd.enable = true;
    };
  };
  # Logging
  system.stateVersion = "25.05"; 
}
