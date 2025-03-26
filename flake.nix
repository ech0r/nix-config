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
  outputs = { nixpkgs, nixvim, home-manager, disko, nixos-wsl, ... }: {
    nixosConfigurations = {
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
       };
       system = "x86_64-linux";
       modules = [
         nixos-wsl.nixosModules.default
         {
           system.stateVersion = "24.05";
           wsl.enable = true;
         }
       ];
     };
    };
  };
}
