{ config, pkgs, lib, ... }:

let
  isWSL = builtins.match ".*[Mm]icrosoft.*" (builtins.readFile "/proc/version") != null;
in
builtins.trace ("isWSL = " + (if isWSL then "true" else "false")) (
{
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
  }
)
