{ config, pkgs, ... }:

{
    home.packages = [
        pkgs.asdf-vm
        pkgs.yaml-cpp
    ];
    programs.nh = {
    enable = true;
  };

    programs = {
        zsh = {
            initExtra = ". $HOME/.nix-profile/share/asdf-vm/asdf.sh";
        };
    };  
}
