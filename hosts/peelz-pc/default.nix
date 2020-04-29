{ modulesPath
, system
, lib
, config
, nixpkgs
, nixpkgs-unstable
, inputs
, ...
}@args:

with lib;
let
  makeUser = path: overrides:
    let
      user = import path;

      userFn = (args: let
        userConfig = (user args);
        specialArgs = inputs.self.mkSpecialArgs {
          inherit system;
          # TODO: pass user overlays
        };
      in lib.foldr recursiveUpdate {} [
        userConfig
        # Inject parameters
        # FIXME: doesn't seem to work; infinite recursion (see comments in hm.nix)
        (if userConfig ? config
          then { config._module.args = specialArgs; }
          else { _module.args = specialArgs; })
        # Inject host-defined overrides
        overrides
      ]);
    # We need to set the function args since we're proxying the call, thus
    # losing the original argset. We recover it using functionArgs.
    in setFunctionArgs userFn (functionArgs user);
in
builtins.trace "__nixpkgs in peelz-pc__"
builtins.trace "nixpkgs=${nixpkgs.lib.version}"
builtins.trace "nixpkgs-unstable=${nixpkgs-unstable.lib.version}"
{
  imports = [
    "${modulesPath}/installer/cd-dvd/iso-image.nix"
  ];

  # System packages
  environment.systemPackages = with nixpkgs; [
    nano
  ];

  # Users
  users.users.peelz = {};
  home-manager.users.peelz = makeUser ./hm.nix {
    # Host-defined overrides for peelz
    # e.g. my.test.enable = false;
  };
}
