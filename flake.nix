{
  description = "John's NixOS Config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixvim = {
      url = "github:ech0r/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixvim, home-manager, disko, nixos-wsl, ... }: 
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
      desktop = nixpkgs.lib.nixosSystem {
        specialArgs = { 
          inherit nixvim; 
          inherit (nixpkgs) lib;
          homeManagerModule = home-manager.nixosModules.home-manager;
        };
        system = "x86_64-linux";
        modules = [ ./hosts/desktop/desktop.nix ];
      }; 
      nuc = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit disko;
          inherit nixvim; 
          inherit (nixpkgs) lib;
        };
        system = "x86_64-linux";
        modules = [ 
          disko.nixosModules.disko
          ./hosts/nuc/nuc.nix 
          ./hosts/nuc/disks.nix
          ./hosts/nuc/hardware-configuration.nix
        ];
     }; 
     wsl = nixpkgs.lib.nixosSystem {
       specialArgs = {
         inherit nixvim;
         inherit (nixpkgs) lib;
         homeManagerModule = home-manager.nixosModules.home-manager;
       };
       system = "x86_64-linux";
       modules = [
         nixos-wsl.nixosModules.default
       ];
     };
     # Let's make a package entry for our WSL tarball
    packages.${system} = {
      # This is our custom package that will build the WSL tarball
      wsl = with import nixpkgs { inherit system; }; 
        let
          # Create a derivation that calls the official tarball builder
          tarball = runCommand "nixos-wsl-tarball" { } ''
            mkdir -p $out
            ${nixos-wsl.packages.${system}.nixos-wsl}/bin/nixos-wsl-tarball-builder -c ${self.nixosConfigurations.wsl.config.system.build.toplevel} -o $out/nixos-wsl.tar.gz
          '';
        in tarball;
    };
  };
}
