{
  description = "My Home Manager configuration for macOS and WSL";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    mac-app-util.url = "github:hraban/mac-app-util";
    # mac-os-config = { url = "path:/home/zaidb/.config/home-manager/macos/"; };
    # wsl-config = { url = "path:/home/zaidb/.config/home-manager/wsl"; };
  };

  outputs = { self, nixpkgs, home-manager, mac-app-util, ... }: let
    username = "zaidb";

in {
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
        mac-app-util.homeManagerModules.default
        ({ pkgs, ... }: {
          home = {
            username = username;
            homeDirectory = "/home/${username}";
            stateVersion = "24.11";
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

