# Create a fake nixos config with nixFlakes enabled so that we can include
# flake-compatible nix tools (and nixos-rebuild)
with import <nixpkgs/nixos> {
  configuration = {
    nix.package = (import <nixpkgs> {}).nixFlakes;
  };
};

with pkgs.lib;
pkgs.mkShell {
  buildInputs = with config.system.build; with pkgs; [
    nixos-rebuild
    nixFlakes
    (writeShellScriptBin "rebuild" ''
      ${nixos-rebuild}/bin/nixos-rebuild build --flake .#peelz-pc
    '')
  ];

  NIX_CONF_DIR = let
    current = optionalString
      (builtins.pathExists /etc/nix/nix.conf)
      (builtins.readFile /etc/nix/nix.conf);

    nixConf = pkgs.writeTextDir "opt/nix.conf" ''
      ${current}
      experimental-features = nix-command flakes ca-references
    '';
  in "${nixConf}/opt";

  shellHook = ''
    echo Type `rebuild` to rebuild peelz-pc.
  '';
}
