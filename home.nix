{ self, config, lib, pkgs, inputs, ... }:

let
  # Reference the nvim package from the nixvim flake
  nvim = inputs.nixvim.packages.x86_64-linux.default;
in
{

  home.username = "john";
  home.homeDirectory = "/home/john";

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 12;
    "Xft.dpi" = 96;
  };

  # Packages that should be installed to the user profile
  home.packages = with pkgs; [
    ifuse
    nvim  # Reference the nvim package from nixvim flake
    spotify
    firefox
    chromium
    vlc

    # gaming
    steam
    lutris
    wine 
    winetricks

    # engineering
    gnuradio

    neofetch
    nnn # terminal file manager

    # email

    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    jq # A lightweight and flexible command-line JSON processor
    eza # A modern replacement for ‘ls’
    fzf # A command-line fuzzy finder
    gparted # disk utility

    # networking tools
    mtr # A network diagnostic tool
    iperf3
    dnsutils  # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc  # it is a calculator for the IPv4/v6 addresses

    # misc
    cowsay
    file
    which
    tree
    gnused
    gnutar
    gawk
    zstd
    gnupg

    # development
    gdb
    vscode
    
    # LSPs
    rust-analyzer
    gopls
    zls

    # nix related
    nix-output-monitor

    # productivity
    hugo # static site generator
    glow # markdown previewer in terminal

    btop  # replacement of htop/nmon
    iotop # io monitoring
    iftop # network monitoring

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb

    # emulation
    ryujinx
  ];

  # email setup with protonmail-bridge
  #programs.mbsync = {
  #  enable = true;
  #  accounts = {
  #    protonmail-personal = {
  #      imap = {
  #        host = "127.0.0.1";
  #        port = 1143;
  #        user = "john@coyote.technology";
  #        passwordFile = "~/.maildir/protonmail-coyote-technology/pass.gpg";
  #        sslType = "NONE";
  #      };
  #      maildir = {
  #        path = "~/.maildir/protonmail-coyote-technology";
  #      };
  #
  #    };
  #    protonmail-coyote-technology = {
  #      imap = {
  #        host = "127.0.0.1";
  #        port = 1143;
  #        user = "john@coyote.technology";
  #        passwordFile = "~/.maildir/protonmail-coyote-technology/pass.gpg";
  #        sslType = "NONE";
  #      };
  #      maildir = {
  #        path = "~/.maildir/protonmail-coyote-technology";
  #      };
  #    };
  #  };
  #};
  
  # basic configuration of git
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

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  home.stateVersion = "23.11";

  # Let home Manager install and manage itself
  programs.home-manager.enable = true;
}

