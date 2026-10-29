{ lib, wsl, ... }:

{
  # GUI apps are skipped on WSL; chromium extensions and the Stream Deck plugin go to
  # Windows there.
  imports = [
    ./chromium/config.nix
    ./streamdeck/config.nix
  ]
  ++ lib.optionals (!wsl) [
    # ./vscode/config.nix
    ./config-darwin.nix
    ./config-linux.nix
  ];
}
