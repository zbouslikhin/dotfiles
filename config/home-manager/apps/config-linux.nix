{
  config,
  pkgs,
  lib,
  ...
}:

lib.mkIf (config.home.sessionVariables.activeOS == "linux") {
  home.packages = with pkgs; [
    vscode
    spotify
    brave
    google-chrome
    wireguard-ui
    obsidian
  ];
}
