{ config, pkgs, ... }:

{
    home.packages = [
        pkgs.spotify
        pkgs.arc-browser
        pkgs.brave
        pkgs.wireguard-ui
    ];
}
