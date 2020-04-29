{ lib
, config
, nixpkgs
, nixpkgs-unstable
, ...
}@args:

# FIXME: why does this result in an infinite recursion? D:
# builtins.trace "__nixpkgs in users/peelz__"
# builtins.trace "nixpkgs=${nixpkgs.lib.version}"
# builtins.trace "nixpkgs-unstable=${nixpkgs-unstable.lib.version}"
{
  imports = [ ./hm-module-test.nix ];

  # FIXME: uncomment this and it'll cause an infinite recursion -.-
  #config = nixpkgs.lib.mkIf true {
  config = {
    home.packages = with nixpkgs-unstable; [
      hello
    ];

    my.test.enable = true;
  };
}
