{ inputs, config, pkgs, lib, ... }:

{
  imports = [
    # Import Home Manager as a module
    (inputs.home-manager.nixosModules.home-manager)
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit inputs; };
  home-manager.users.john = import ./home.nix;
}
