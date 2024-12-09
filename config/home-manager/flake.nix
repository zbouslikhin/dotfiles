{
  description = "My Home Manager configuration for macOS and WSL";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = { self, nixpkgs, home-manager, mac-app-util, ... }: let
    username = "zaidb";

in {
    devShells.default = nixpkgs.mkShell {
      buildInputs = []; # Add dependencies here if needed
      shellHook = ''
         export MY_ENV_VAR="Hello world Z"
         echo "Environment variable MY_ENV_VAR is set to: $MY_ENV_VAR"
      '';
    };
    homeConfigurations = {
      # # macOS configuration
      # zaidb-macos = home-manager.lib.homeManagerConfiguration {
      #   modules = [
      #     ./macos/flake.nix
      #   ];
      #   pkgs = import nixpkgs { system = "aarch64-darwin"; config.allowUnfree = true; };
      #   username = username;
      # };

      # WSL configuration
      # TODO: move to separate file once relative paths work
      # https://github.com/NixOS/nix/issues/3978
      zaidb-wsl = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
        modules = [
          ({ pkgs, lib, ... }: {
            home = {
              username = username;
              homeDirectory = "/home/${username}";
              stateVersion = "24.11";
              activation = {
                makePotato = lib.hm.dag.entryAfter ["writeBoundary"] ''
                  #!/bin/bash

# Define source and destination paths
SOURCE="/mnt/c/Users/zaid/.ssh"
DEST="$HOME/.ssh"

# Check if the source folder exists
if [ -d "$SOURCE" ]; then
  echo "Found folder: $SOURCE"

  # Create the destination directory if it doesn't exist
  mkdir -p "$DEST"
  
  # Copy the folder
  cp -r "$SOURCE"/* "$DEST"
  chmod -R 700 "$DEST"/*
        echo "Set permissions to 600 for all keys in $DEST"
  
  echo "Contents of $SOURCE copied to $DEST"
else
  echo "Folder $SOURCE does not exist. Nothing to copy."
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
              # ./apps
            ];
            
          })
      ];       
      };
    };
  };
}

