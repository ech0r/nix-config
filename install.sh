#!/usr/bin/env bash

NIX_CONFIG="experimental-features nix-command flakes"

nix run github:nix-community/disko/latest -- mode destroy,format,mount "./hosts/$1/disks.nix"

nixos-generate-config --root /mnt

nixos-install --flake .#nuc --impure
