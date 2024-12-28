{
  description = "Home Manager with Custom Configuration and NixVim";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim.url = "path:/etc/nixos/nixvim";  # Reference to your local nixvim flake
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { nixpkgs, nixvim, home-manager, ... }@inputs: {
    homeManager = home-manager.lib.homeManagerConfiguration {
      inherit inputs;

      home.username = "john";
      home.homeDirectory = "/home/john";

      # Set cursor size and dpi for 4k monitor
      xresources.properties = {
        "Xcursor.size" = 12;
        "Xft.dpi" = 96;
      };

      # Packages to be installed
      home.packages = with nixpkgs; [
        ifuse
        nixvim.packages.default  # Use nvim from your nixvim flake

        spotify
        firefox
        chromium
        vlc
        steam
        lutris
        wine
        winetricks
        gnuradio
        neofetch
        nnn
        ledger
        zip
        xz
        unzip
        p7zip
        ripgrep
        jq
        eza
        fzf
        gparted
        mtr
        iperf3
        dnsutils
        ldns
        aria2
        socat
        nmap
        ipcalc
        cowsay
        file
        which
        tree
        gnused
        gnutar
        gawk
        zstd
        gnupg
        gdb
        vscode
        rust-analyzer
        gopls
        zls
        nix-output-monitor
        hugo
        glow
        btop
        iotop
        iftop
        strace
        ltrace
        lsof
        sysstat
        lm_sensors
        ethtool
        pciutils
        usbutils
        ryujinx
      ];

      # Git configuration
      programs.git = {
        enable = true;
        userName = "ech0r";
        userEmail = "john@coyote.tech";
        extraConfig = {
          credential.helper = "${
            pkgs.git.override { withLibsecret = true; }
          }/bin/git-credential-libsecret";
        };
      };

      # Bash configuration
      programs.bash = {
        enable = true;
        enableCompletion = true;
        bashrcExtra = ''export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"'';
        shellAliases = {
          vim = "nvim";
          lah = "ls -lath";
          la = "ls -a";
          l = "ls";
        };
      };

      # Home Manager version
      home.stateVersion = "23.11";

      # Enable Home Manager itself
      programs.home-manager.enable = true;
    };

    # NixOS configurations
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix  # Your NixOS config
          home-manager.nixosModules.home-manager
        ];
      };
    };
  };
}

