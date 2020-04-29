{ lib
, config
, nixpkgs
, nixpkgs-unstable
, ...
}@args:

with lib;
let
  cfg = config.my.test;
in {
  options.my.test = {
    enable = mkEnableOption "Test";
  };

  config = mkIf cfg.enable {
    home.packages = (with nixpkgs-unstable; [
      neofetch
    ]) ++ (with nixpkgs; [
      neovim
    ]);
  };
}
