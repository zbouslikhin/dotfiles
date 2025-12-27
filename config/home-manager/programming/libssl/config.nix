{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.openssl
  ];

}
