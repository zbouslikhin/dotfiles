{ lib, wsl, ... }:

{
  # GUI apps are skipped on WSL; chromium extensions go to Windows' browsers there.
  imports = [
    ./chromium/config.nix
  ]
  ++ lib.optionals (!wsl) [
    # ./vscode/config.nix
    ./config-darwin.nix
    ./config-linux.nix
  ];
}
