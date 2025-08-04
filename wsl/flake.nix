{
  description = "John's NixOS WSL flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:ech0r/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixvim, nixos-wsl }:
  let
    system = "x86_64-linux";
    nvim = nixvim.packages.${system}.default;
  in {
    nixosConfigurations.custom-wsl = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        nixos-wsl.nixosModules.default
        ({ pkgs, ... }: {
          wsl = {
            enable = true;
            defaultUser = "nixos";
            # You can customize further as needed
          };
          
          # Add your custom NixOS configuration here
          environment.systemPackages = with pkgs; [
            # Include the nixvim package from the flake input
            nvim
            
            # Include other packages from nixpkgs
            vim
            git
            curl
            wget
          ];
          
          # Set your time zone
          time.timeZone = "America/Los_Angeles";
          
          system.stateVersion = "25.11";
        })
      ];
    };
    apps.${system} = {
      default = {
        type = "app";
        program = toString (nixpkgs.legacyPackages.${system}.writeShellScript "build-wsl" ''
          PATH="${nixpkgs.legacyPackages.${system}.coreutils}/bin:$PATH"
          
          if [ "$(id -u)" -ne 0 ]; then
            echo "This script must be run as root (sudo nix run)" >&2
            exit 1
          fi
          
          output_file="''${1:-nixos.wsl}"
          echo "Building custom NixOS-WSL tarball at $output_file..."
          ${self.nixosConfigurations.custom-wsl.config.system.build.tarballBuilder}/bin/nixos-wsl-tarball-builder "$output_file"
          echo "Successfully built WSL tarball at $output_file"
        '');
      };
    };
  };
}
