{ config, pkgs, ... }:

{
    home.packages = [
        pkgs.asdf-vm
        pkgs.awscli
    ];

    programs = {
        zsh = {
            initExtra = ". $HOME/.nix-profile/share/asdf-vm/asdf.sh";
        };
    };  
}
