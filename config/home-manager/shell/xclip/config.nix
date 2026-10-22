{
  lib,
  config,
  pkgs,
  ...
}:

lib.mkIf pkgs.stdenv.isLinux {
  home.packages = [
    pkgs.xclip
  ];
}
