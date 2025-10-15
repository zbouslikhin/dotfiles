{ config, pkgs, lib, ... }:

let
  isWSL = builtins.getEnv "WSL_DISTRO_NAME" != "";
in
lib.mkIf (!isWSL) {
  nixpkgs.config.permittedInsecurePackages = [
    "arc-browser-1.106.0-66192"
  ];

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "spotify"
      "arc-browser"
      "google-chrome"
      "vscode"
      "vscode-pylance"
      "vscode-extension-MS-python-vscode-pylance"
      "the-unarchiver"
    ];

  home.packages = with pkgs; [
    spotify
    arc-browser
    google-chrome
    wireguard-ui
    the-unarchiver
  ];
}
