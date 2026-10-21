{
  config,
  pkgs,
  lib,
  hmDir,
  ...
}:

lib.mkIf pkgs.stdenv.isDarwin {
  programs.alacritty = {
    enable = true;
  };

  xdg.configFile = {
    alacritty = {
      source = config.lib.file.mkOutOfStoreSymlink "${hmDir}/terminals/alacritty/alacritty";
    };
  };

}
