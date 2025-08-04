{ config, pkgs, lib, nixvim, homeManagerModule, ... }:

{
  imports = [
    homeManagerModule
  ];
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.john = import ./john.nix {
    inherit config pkgs lib nixvim;
  };
}
