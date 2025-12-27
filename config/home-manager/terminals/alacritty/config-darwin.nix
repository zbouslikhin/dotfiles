{
  config,
  pkgs,
  lib,
  ...
}:

lib.mkIf (config.home.sessionVariables.activeOS == "darwin") {
  programs.alacritty = {
    enable = true;
  };

  xdg.configFile = {
    alacritty = {
      source = config.lib.file.mkOutOfStoreSymlink "${builtins.toString ./.}/alacritty/";
      recursive = true;
    };
  };

}
