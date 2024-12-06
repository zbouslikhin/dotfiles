{ config, pkgs, ... }:

{
    home.packages = [
      pkgs.lazygit
    ];

    programs = {
        neovim = {
            enable = true;
        };
    };  

    xdg.configFile = {
      nvim = {
          source =
              config.lib.file.mkOutOfStoreSymlink
              "${builtins.toString ./.}/lazyvim";
          recursive = true;
      };
    };
}
