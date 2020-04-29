{
  description = "Flakes config with home-manager integration";

  edition = 201909;

  inputs = {
    nixpkgs.url = "nixpkgs/release-20.03";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager.url = "github:louistakepillz/home-manager/release-20.03-flakes-test";
  };

  outputs = inputs: {
    nixosConfigurations = import ./hosts inputs;

    mkSpecialArgs = { system, overlays ? [] }: let
      mkPkgs = input: import inputs.${input} {
        inherit system overlays;
        config.allowUnfree = true;
      };

      pkgArgs = with inputs.nixpkgs.lib; {
        inherit inputs;
        # Let the host know what system arch it's on
        inherit system;
        WUT = 5;
      } // genAttrs
        # Import & inject all inputs beginning with "nixpkgs"
        (filter
          (hasPrefix "nixpkgs")
          (attrNames inputs))
        mkPkgs;
    in pkgArgs // {
      # Replace "lib" with the one from `inputs.nixpkgs`
      # since we're not sure where the old one comes from?!
      inherit (pkgArgs.nixpkgs) lib;
    };
  };
}
