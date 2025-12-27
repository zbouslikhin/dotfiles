{
  config,
  pkgs,
  lib,
  ...
}:

lib.mkIf (config.home.sessionVariables.activeOS == "linux") {
  programs.alacritty = {
    enable = true;
  };

  xdg.configFile = {
    alacritty = {
      source = config.lib.file.mkOutOfStoreSymlink "${builtins.toString ./.}/alacritty/";
      recursive = true;
    };
  };

  xdg.desktopEntries.alacritty = {
    name = "Alacritty";
    genericName = "Terminal";
    comment = "A fast, cross-platform OpenGL terminal emulator";
    exec = "${config.home.homeDirectory}/.nix-profile/bin/nixGL alacritty";
    terminal = false;
    categories = [
      "System"
      "TerminalEmulator"
    ];
    icon = "Alacritty";
  };

}
