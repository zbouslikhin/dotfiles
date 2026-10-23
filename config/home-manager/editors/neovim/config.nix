{
  config,
  pkgs,
  lib,
  hmDir,
  ...
}:

{
  home.packages = [
    pkgs.lazygit
  ];

  programs = {
    neovim = {
      enable = true;
      # init.lua comes from the linked lazyvim folder; HM's own settings load via the wrapper.
      sideloadInitLua = true;
      extraPackages = [
        pkgs.fd
        pkgs.nodejs
        # nvim-treesitter (main branch) builds parsers with the tree-sitter CLI.
        pkgs.tree-sitter
      ] ++ lib.optionals pkgs.stdenv.isLinux [ pkgs.wl-clipboard ];
    };
  };

  xdg.configFile = {
    nvim = {
      source = config.lib.file.mkOutOfStoreSymlink "${hmDir}/editors/neovim/lazyvim";
    };
  };
}
