{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.asdf-vm
  ];
  programs = {
    zsh = {
      initExtra = ". $HOME/.nix-profile/share/asdf-vm/asdf.sh";
    };
  };
}
