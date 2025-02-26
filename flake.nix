{
  description = "John's NixOS Config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixvim = {
      # url = "github:ech0r/nix-config/nixvim";
       url = "path:/home/john/dev/nix-config/nixvim";
      # url = "github:nix-community/nixvim";
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
  };
  outputs = { nixpkgs, nixvim, home-manager, disko, ... }: {
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
    };
  };
}
