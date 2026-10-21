{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.asdf-vm
  ];
  programs = {
    zsh = {
      # asdf 0.16+ has no asdf.sh; putting the shims on PATH is all it needs.
      initContent = ''export PATH="''${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"'';
    };
  };
}
