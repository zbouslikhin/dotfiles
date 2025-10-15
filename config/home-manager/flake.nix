{
  description = "Zaid Home Manager configuration for macOS and WSL using flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = { self, nixpkgs, home-manager, mac-app-util, ... }: let
    username = "zaidb";
    root = "home";

in {
    homeConfigurations = {
      # # macOS configuration
      zaidb-macos = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-darwin"; 
          config.allowUnfree = true; 
        };
        modules = [
          ({ pkgs, lib, ... }: {
            home = {
              username = username;
              homeDirectory = "/${root}/${username}";
              stateVersion = "25.11";
            };

            imports = [
              ./editors
              ./shell
              ./programming
              ./fonts
              ./terminals
              ./apps
            ];
          })
        ];       
      };

      # WSL configuration
      # TODO: move to separate file once relative paths work
      # https://github.com/NixOS/nix/issues/3978
      zaidb-wsl = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
        modules = [
          ({ pkgs, lib, ... }: {
            home = {
              username = username;
              homeDirectory = "/${root}/${username}";
              stateVersion = "24.11";
              activation = {
                copyWinSshKeys = lib.hm.dag.entryAfter ["writeBoundary"] ''
#!/bin/bash
SCRIPT="/${root}/${username}/.config/home-manager/copy_ssh.sh"
if [ -f "$SCRIPT" ]; then
  source $SCRIPT
else
  echo "$SCRIPT does not exist"
fi
                '';
              };
            };

            imports = [
              ./editors
              ./shell
              ./programming
              ./fonts
              ./terminals
            ];
            
          })
      ];       
      };
    };
  };
}


