{ config, pkgs, lib, ... }:

let
  # Detect WSL by checking for the WSL_DISTRO_NAME environment variable.
  isWSL = builtins.getEnv "WSL_DISTRO_NAME" != "";
in
{
  config = lib.mkIf (!isWSL) {
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (pkgs.lib.getName pkg) [ "vscode" ];

    programs.vscode = {
      enable = true;
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      mutableExtensionsDir = true;

      userSettings = {
        "editor.fontSize" = 10;
      };
    };
  };
}
