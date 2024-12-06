{ config, pkgs, lib, ... }:

{
    home.packages = [
        pkgs.zellij
    ];

    programs.zellij = {
        enable = true;
        enableZshIntegration = true;
        enableFishIntegration = true;
        enableBashIntegration = true;
    };

    xdg.configFile = {
      zellij = {
        source =
                config.lib.file.mkOutOfStoreSymlink
                "${builtins.toString ./.}/zellij";
            recursive = true;
      };
    };
}
