{
  config,
  pkgs,
  lib,
  ...
}:

lib.mkIf pkgs.stdenv.isDarwin {
  home.packages = with pkgs; [
    spotify
    brave
    google-chrome
    wireguard-ui
    the-unarchiver
  ];
}
