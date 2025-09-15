{ config, pkgs, lib, ... }:

# let
#   isNotWSL = !builtins.hasAttr "WSL_DISTRO_NAME" (builtins.getEnv "WSL_DISTRO_NAME");
# in
{
  nixpkgs.config.permittedInsecurePackages = [
    "arc-browser-1.106.0-66192"
  ];
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "spotify"
      "arc-browser"
      "google-chrome"

      # this needs to be  /
      "vscode"
      "vscode-pylance"
      "vscode-extension-MS-python-vscode-pylance"
      "the-unarchiver"
    ];

  home.packages = [
    pkgs.spotify
    pkgs.arc-browser
    pkgs.google-chrome
    # pkgs.brave
    pkgs.wireguard-ui
    pkgs.the-unarchiver
  ];
}
