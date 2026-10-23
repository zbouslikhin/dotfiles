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
    # zsh starts zellij itself below, so it can skip herdr panes.
    enableZshIntegration = false;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };

  # Same auto-start Home Manager would add, except inside herdr (it sets HERDR_ENV=1),
  # which is a multiplexer of its own.
  programs.zsh.initContent = lib.mkOrder 200 ''
    if [[ -z "$HERDR_ENV" ]]; then
      eval "$(${lib.getExe config.programs.zellij.package} setup --generate-auto-start zsh)"
    fi
  '';

  xdg.configFile = {
    zellij = {
      source = config.lib.file.mkOutOfStoreSymlink "${hmDir}/shell/zellij/zellij";
    };
  };
}
