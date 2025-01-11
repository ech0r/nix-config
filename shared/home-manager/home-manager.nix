{ inputs, config, pkgs, lib, ... }:

{
  imports = [
    (inputs.home-manager.nixosModules.home-manager)
  ];
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.john = import ./home.nix {
    inherit inputs;
    inherit lib;
  };
}
