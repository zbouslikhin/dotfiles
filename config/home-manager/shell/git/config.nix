{ config, pkgs, ... }:

{
  # Needed by lazy.nvim's bootstrap; a new Ubuntu has no git.
  home.packages = [
    pkgs.git
  ];
}
