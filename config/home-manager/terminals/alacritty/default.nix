{ lib, wsl, ... }:

{
  # Windows runs its own terminal, so alacritty is skipped on WSL.
  imports = lib.optionals (!wsl) [
    ./config-linux.nix
    ./config-darwin.nix
  ];
}
