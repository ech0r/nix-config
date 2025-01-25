{
  description = "Minimal Installer with SSH and root login";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  outputs = { self, nixpkgs }: {
    nixosConfigurations = {
      default = nixpkgs.lib.nixosSystem {
        exampleIso = "x86_64-linux";
        modules = [
          ({ pkgs, modulesPath, ... }: {
            imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
            environment.systemPackages = [ pkgs.neovim ];
            users.users.root.openssh.authorizedKeys.keyFiles = [
              ../../shared/authorized_keys
            ];
          })
        ];
      };
    };
  };
}

