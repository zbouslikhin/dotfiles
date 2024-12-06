{
  description = "My Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = { self, nixpkgs, home-manager, mac-app-util, ... }: let
    username = "zaidb";
    system = "aarch64-darwin";
  in {
    homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
      modules = [
        mac-app-util.homeManagerModules.default
        ({ pkgs, ... }: {
          home = {
            username = username;
            homeDirectory = "/Users/${username}";
            stateVersion = "24.11";
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
  };
}

