{ config, pkgs, lib, ... }:

# let
#   isNotWSL = !builtins.hasAttr "WSL_DISTRO_NAME" (builtins.getEnv "WSL_DISTRO_NAME");
# in
{
  home.packages = [
    # pkgs.spotify
    pkgs.arc-browser
    # pkgs.brave
    pkgs.wireguard-ui
  ];
}
