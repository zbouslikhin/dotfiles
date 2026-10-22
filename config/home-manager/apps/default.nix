{ lib, wsl, ... }:

{
  # GUI apps are skipped on WSL.
  imports = lib.optionals (!wsl) [
    # ./vscode/config.nix
    ./config-darwin.nix
    ./config-linux.nix
  ];
}
