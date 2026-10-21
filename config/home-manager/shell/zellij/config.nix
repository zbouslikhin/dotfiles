{
  config,
  pkgs,
  lib,
  hmDir,
  ...
}:

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
      source = config.lib.file.mkOutOfStoreSymlink "${hmDir}/shell/zellij/zellij";
      recursive = true;
    };
  };
}
