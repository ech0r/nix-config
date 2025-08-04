{ config, pkgs, lib, nixvim, ... }:

let
  # Reference the nvim package from the nixvim flake
  nvim = nixvim.packages.x86_64-linux.default;
in
{

  home.username = "john";
  home.homeDirectory = "/home/john";
  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 12;
    "Xft.dpi" = 110;
  };

  # Packages that should be installed to the user profile
  home.packages = with pkgs; [
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    btop  # replacement of htop/nmon
    caligula # utility for disk imaging
    chromium
    cowsay
    dnsutils  # `dig` + `nslookup`
    emacs
    ethtool
    eza # A modern replacement for ‘ls’
    file
    firefox
    ffmpeg-full
    fzf # A command-line fuzzy finder
    gawk
    gdb
    glow # markdown previewer in terminal
    gnupg
    gnuradio
    gnused
    gnutar
    gopls
    gparted # disk utility
    gzip
    htop
    hugo # static site generator
    iftop # network monitoring
    ifuse
    inetutils
    iotop # io monitoring
    ipcalc  # it is a calculator for the IPv4/v6 addresses
    iperf3
    jq # A lightweight and flexible command-line JSON processor
    kitty
    ldns # replacement of `dig`, it provide the command `drill`
    lm_sensors # for `sensors` command
    lsof # list open files
    ltrace # library call monitoring
    lutris
    mtr # A network diagnostic tool
    neofetch
    nh # nix cli helper
    nix-output-monitor
    nixos-anywhere
    nmap # A utility for network discovery and security auditing
    nnn # terminal file manager
    nvim  # Reference the nvim package from nixvim flake
    p7zip
    pciutils # lspci
    progress
    ripgrep # recursively searches directories for a regex pattern
    rust-analyzer
    ryujinx
    simple-http-server
    socat # replacement of openbsd-netcat
    steam
    strace # system call monitoring
    sysstat
    tcptraceroute
    tmux
    tree
    unzip
    usbutils # lsusb
    vlc
    vscode
    which
    wine 
    winetricks
    xz
    zip
    zls
    zstd
  ];

  programs.kitty = lib.mkForce {
    enable = true;
    font = {
      package = pkgs.nerd-fonts.iosevka;
      name = "Iosevka";
      size = 12;
    }; 
    settings = {
      confirm_os_window_close = 0;
      dynamic_background_opacity = true;
      enable_audio_bell = false;
      mouse_hide_wait = "-1.0";
      window_padding_width = 10;
      background_opacity = "0.5";
      background_blur = 5;
      clipboard_control = "write-clipboard write-primary read-clipboard read-primary";
      term = "xterm-256color";
      symbol_map = let
        mappings = [
          "U+23FB-U+23FE"
          "U+2B58"
          "U+E200-U+E2A9"
          "U+E0A0-U+E0A3"
          "U+E0B0-U+E0BF"
          "U+E0C0-U+E0C8"
          "U+E0CC-U+E0CF"
          "U+E0D0-U+E0D2"
          "U+E0D4"
          "U+E700-U+E7C5"
          "U+F000-U+F2E0"
          "U+2665"
          "U+26A1"
          "U+F400-U+F4A8"
          "U+F67C"
          "U+E000-U+E00A"
          "U+F300-U+F313"
          "U+E5FA-U+E62B"
        ];
      in
        (builtins.concatStringsSep "," mappings) + " Symbols Nerd Font Mono";
    };
  };

  # basic configuration of git
  programs.git = {
    enable = true;
    userName = "ech0r";
    userEmail = "john@coyote.technology";
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

