{
  description = "Zaid Home Manager configuration for macOS and WSL using flakes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      mac-app-util,
      ...
    }:
    let
      # Per-machine settings, written by bootstrap.sh and not committed. Lines like
      # KEY="value" are both a shell env file and TOML. The flake must be referenced as
      # `path:<dir>` (NH_FLAKE is), or Nix ignores this gitignored file.
      env = builtins.fromTOML (builtins.readFile ./machine.env);

      mkHome =
        {
          system,
          wsl ? false,
          stateVersion,
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit wsl;
            # This flake inside the checkout, for out-of-store symlinks.
            hmDir = "${env.DOTFILES_DIR}/config/home-manager";
          };
          modules = [
            {
              home = {
                inherit stateVersion;
                username = env.DOTFILES_USER;
                homeDirectory = "${if nixpkgs.lib.hasSuffix "darwin" system then "/Users" else "/home"}/${env.DOTFILES_USER}";
              };
              programs.home-manager.enable = true;

              imports = [
                ./apps
                ./editors
                ./fixes
                ./fonts
                ./programming
                ./shell
                ./terminals
              ];
            }
          ];
        };

      hosts = {
        macos = mkHome {
          system = "aarch64-darwin";
          stateVersion = "25.11";
        };
        wsl = mkHome {
          system = "x86_64-linux";
          wsl = true;
          stateVersion = "24.11";
        };
        ubuntu = mkHome {
          system = "x86_64-linux";
          stateVersion = "24.11";
        };
      };
    in
    {
      # `<username>` is this machine's host, so `nh home switch` needs no `#name`.
      homeConfigurations = hosts // {
        ${env.DOTFILES_USER} = hosts.${env.DOTFILES_HOST};
      };
    };
}
