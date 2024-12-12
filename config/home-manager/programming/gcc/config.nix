{ config, pkgs, ... }:

{
    home.packages = [
        pkgs.gcc
    ];
}
