{
  config,
  pkgs,
  lib,
  hmDir,
  ...
}:

lib.mkIf pkgs.stdenv.isLinux {
  programs.alacritty = {
    enable = true;
  };

  xdg.configFile = {
    alacritty = {
      source = config.lib.file.mkOutOfStoreSymlink "${hmDir}/terminals/alacritty/alacritty";
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
