{ config, pkgs, ... }:

{
    home.packages = with pkgs; [
        (nerdfonts.override { 
            fonts = [ "Hack" ];
        })
    ];

    fonts.fontconfig.enable = true;    
}