{ self
, nixpkgs
, home-manager
, ...
}@inputs:

with nixpkgs.lib;
let
  importHostConfig = name: import (./. + "/${name}");

  mkHost = name: nixosSystem rec {
    system = "x86_64-linux";

    modules = [
      (importHostConfig name)
      ({
        networking.hostName = name;
      })
      home-manager.nixosModules.home-manager
    ];

    specialArgs = self.mkSpecialArgs {
      inherit system;
      # TODO: use host overlays defined within the host config
    };
  };

  hosts = (attrNames (filterAttrs
    (n: v: n != "default.nix" &&
      (v == "directory" || hasSuffix ".nix" n))
    (builtins.readDir ./.)));

in genAttrs hosts mkHost
