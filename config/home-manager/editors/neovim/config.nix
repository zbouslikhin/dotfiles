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
      extraPackages = [
        pkgs.fd
        pkgs.nodejs
      ] ++ lib.optionals pkgs.stdenv.isLinux [ pkgs.wl-clipboard ];
    };
  };

  xdg.configFile = {
    nvim = {
      source = config.lib.file.mkOutOfStoreSymlink "${hmDir}/editors/neovim/lazyvim";
      recursive = true;
    };
  };
}
