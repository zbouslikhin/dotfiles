{
  config,
  pkgs,
  lib,
  ...
}:

{
  home.packages = [
    pkgs.nixfmt-rfc-style
    pkgs.prettier
    pkgs.texlivePackages.latexindent
  ];
}
