{ config, pkgs, ... }:

let
  isNotWSL = !builtins.hasAttr "WSL_DISTRO_NAME" (builtins.getEnv "WSL_DISTRO_NAME");
in
{
  home.packages = lib.mkIf isNotWSL [
    pkgs.spotify
    pkgs.arc-browser
    pkgs.brave
    pkgs.wireguard-ui
  ];
}
