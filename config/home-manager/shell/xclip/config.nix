{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf (config.home.sessionVariables.activeOS == "linux") {
  home.packages = [
    pkgs.xclip
  ];
}
