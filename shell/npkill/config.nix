{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.npkill
  ];
}
