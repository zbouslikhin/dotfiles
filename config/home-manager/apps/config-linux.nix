{
  config,
  pkgs,
  lib,
  ...
}:

lib.mkIf pkgs.stdenv.isLinux {
  home.packages = with pkgs; [
    vscode
    spotify
    brave
    google-chrome
    wireguard-ui
    obsidian
    anydesk
  ];
}
