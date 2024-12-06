{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.wget
  ];
}
