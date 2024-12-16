{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.unzip
  ];
}
