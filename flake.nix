{
  description = "John's NixOS Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixvim = {
      url = "path:./nixvim";
      #url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, nixvim, home-manager, ... }@inputs: {
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
      netboot = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit nixvim;
          inherit (nixpkgs) lix;
        };
        system = "x86_64-linux";
        modules = [ ./hosts/server/netboot.nix ];
     };
  };
}
