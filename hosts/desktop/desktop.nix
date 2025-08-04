{ config, pkgs, lib, nixvim, ... }:
{
  imports = [ 
    ../../shared/home-manager/home-manager.nix
    ./hardware-configuration.nix
  ];

        # ==== BOOT ==== 
        boot.loader.systemd-boot.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;
          boot.initrd.luks.devices."luks-2d406786-24e7-4317-8bb2-2b78bb9a9931".device = "/dev/disk/by-uuid/2d406786-24e7-4317-8bb2-2b78bb9a9931";
          boot.kernelParams = [ 
            "ipv6.disable" 
            "nvidia-drm.modeset=1"
          ];

          boot.binfmt.emulatedSystems = [
            "aarch64-linux"
          ];

        # ==== NETWORK ====
          networking = {
            hostName = "tower"; 
            hostId = "28133080";
            networkmanager.enable = false;
            useDHCP = false; 
            enableIPv6 = false;
            interfaces = {
              enp6s0.ipv4.addresses = [{
                address = "192.168.1.7";
                prefixLength = 24;
              }];
            };
            defaultGateway = {
              address = "192.168.1.1";
              interface = "enp6s0";
            };
            nameservers = [ "192.168.1.5" "1.1.1.1" ];
            firewall = {
              enable = true;
              allowedTCPPorts = [ 22 8080 57621 ];
              allowedUDPPorts = [ 5353 ];
            };
          };

        # ==== Services ====
          services.tailscale = {
            enable = true;
          };

          services.openssh = {
            enable = true;
          };

          services.avahi = {
            enable = true; # Enable Avahi for network discovery
            nssmdns4 = true;
          };
          
          hardware.bluetooth = {
            enable = true; # enables support for Bluetooth
            powerOnBoot = true; # powers up the default Bluetooth controller on boot
            settings = {
              General = {
                Privacy = "device";
                JustWorksRepairing = "always";
                Class = "0x000100";
                FastConnectable = "true";
              };
            };
          };


        # ==== ENVIRONMENT ====
          environment.variables = {
            NIXPKGS_ALLOW_UNFREE = "1";
          };

        # ==== NIX FLAKES ====
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          nix.settings.extra-platforms = [ "aarch64-linux" ];
        # trusted users
          nix.settings.trusted-users = [ "john" ];


        # ==== UNFREE PACKAGES ====
          nixpkgs.config.allowUnfree = true;

        # ==== TIMEZONE ====
          time.timeZone = "America/Los_Angeles";

        # ==== LOCALE ====
          i18n.defaultLocale = "en_US.UTF-8";
          i18n.extraLocaleSettings = {
            LC_ADDRESS = "en_US.UTF-8";
            LC_IDENTIFICATION = "en_US.UTF-8";
            LC_MEASUREMENT = "en_US.UTF-8";
            LC_MONETARY = "en_US.UTF-8";
            LC_NAME = "en_US.UTF-8";
            LC_NUMERIC = "en_US.UTF-8";
            LC_PAPER = "en_US.UTF-8";
            LC_TELEPHONE = "en_US.UTF-8";
            LC_TIME = "en_US.UTF-8";
          };

        # ==== X11 ====
          services.xserver = {
            enable = true;
            xkb.layout = "us";
            xkb.variant = "";
            displayManager = {
              sessionCommands = ''
                xset -dpms 
                xset s off
                xset s noblank
              '';
            };
          };

        # ==== AUDIO ====
          #sound.enable = true;
          services.pulseaudio.enable = false;
          security.rtkit.enable = true;
          services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
          };

        # ==== KDE ====
        services.displayManager = {
          sddm.enable = true;
        };

        services.xserver.desktopManager.plasma6.enable = true;

        # ==== FONTS ====;
        fonts = {
          fontconfig = {
            hinting = {
              style = "full";
              enable = true;
            };
            antialias = true;
          };
          packages = with pkgs; [
            cantarell-fonts
            nerd-fonts.iosevka
            nerd-fonts.fira-code
	    nerd-fonts.symbols-only
	    nerd-fonts.droid-sans-mono
          ];
        };


        # ==== NVIDIA ====
        hardware.graphics = {
          enable32Bit = true;
          enable = true;
        };

        services.xserver.videoDrivers = ["nvidia"];
        hardware.nvidia = {
          modesetting.enable = true;
          powerManagement.enable = false;
          powerManagement.finegrained = false;
          open = false;
          nvidiaSettings = true;
          package = config.boot.kernelPackages.nvidiaPackages.stable;
        }; 

        # ==== UDEV ====
        services.udev.extraRules = ''
        # iPhone
        SUBSYSTEM=="usb", ATTR{idVendor}=="05ac", MODE="0666", GROUP="plugdev"
        ${builtins.readFile ../../shared/udev/50-zsa.rules}
        ${builtins.readFile ../../shared/udev/50-stm.rules}
        ${builtins.readFile ../../shared/udev/69-probe-rs.rules}
        '';

        # ==== CUPS ====
        services.printing.enable = true;

        # ==== USERS ====
        users.users.john = {
          isNormalUser = true;
          description = "john";
          extraGroups = [ "networkmanager" "wheel" "docker" "plugdev" ];
        };

        # ==== BASH ====
        programs.bash = {
          interactiveShellInit = ''eval "$(direnv hook bash)"'';
          shellAliases = {
            vim = "nvim";
          };
        }; 

        # ==== VIRTUALIZATION ====
        virtualisation.docker.enable = true;
        virtualisation.libvirtd.enable = true;
        virtualisation.spiceUSBRedirection.enable = true;
        
        programs.virt-manager.enable = true;
        users.groups.libvirtd.members = [ "john" ];


        # ==== GROUPS ====
        users.groups.plugdev = {
          gid = 132;
        };

        # ==== SYSTEM PACKAGES ====
        environment.systemPackages = with pkgs; [
          grub2
          gcc
          direnv
          docker
          docker-compose
          git 
          xclip
          qemu
          linuxKernel.packages.linux_zen.xpadneo
          # iphone connectivity
          libimobiledevice
          ifuse
          usbmuxd
          # nfs
          nfs-utils
          spotify-player
        ];

        # ==== SPOTIFY ====

        # ==== SYSTEM STATE VERSION ====
        # This value determines the NixOS release from which the default
        # settings for stateful data, like file locations and database versions
        # on your system were taken. It‘s perfectly fine and recommended to leave
        # this value at the release version of the first install of this system.
        # Before changing this value read the documentation for this option
        # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
        system.stateVersion = "23.11"; # Did you read the comment?
    }
