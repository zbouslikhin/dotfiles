{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.packages = [
    pkgs.nixfmt-rfc-style
  ];
}
