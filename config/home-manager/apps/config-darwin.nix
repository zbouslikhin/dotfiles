{
  config,
  pkgs,
  lib,
  ...
}:

lib.mkIf pkgs.stdenv.isDarwin {
  home.packages = with pkgs; [
    spotify
    arc-browser
    google-chrome
    wireguard-ui
    the-unarchiver
  ];
}
