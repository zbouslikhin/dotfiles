{ config, pkgs, ... }:

{
    programs.starship = {
        enable = true;
        enableZshIntegration = true;
        enableFishIntegration = true;
        enableBashIntegration = true;
    };
}
