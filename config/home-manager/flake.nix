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
      lib = nixpkgs.lib;

      # Per-machine settings live in machine.env (gitignored, written by bootstrap.sh).
      # A flake in a git repo only sees tracked files, so it must be referenced as
      # `path:<dir>` for machine.env to be visible. NH_FLAKE is set that way.
      envFile = ./. + "/machine.env";
      env =
        if builtins.pathExists envFile then
          lib.listToAttrs (
            map
              (
                line:
                let
                  m = builtins.match "[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)=\"?([^\"]*)\"?[[:space:]]*" line;
                in
                lib.nameValuePair (builtins.elemAt m 0) (builtins.elemAt m 1)
              )
              (
                builtins.filter (
                  line: builtins.match "[[:space:]]*[A-Za-z_][A-Za-z0-9_]*=.*" line != null
                ) (lib.splitString "\n" (builtins.readFile envFile))
              )
          )
        else
          { };

      required =
        name:
        env.${name} or (throw ''
          ${name} is not set. Create config/home-manager/machine.env (see machine.env.example,
          or run bootstrap.sh) and reference the flake as `path:<dir>` so Nix can see it.
        '');

      username = required "DOTFILES_USER";

      mkHome =
        {
          system,
          host,
          wsl ? false,
          stateVersion,
        }:
        let
          isDarwin = lib.hasSuffix "darwin" system;
          homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
          dotfilesDir = env.DOTFILES_DIR or "${homeDirectory}/dotfiles";
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = {
            inherit host wsl dotfilesDir;
            # Absolute path of this flake inside the checkout, for out-of-store symlinks.
            hmDir = "${dotfilesDir}/config/home-manager";
          };
          modules = [
            {
              home = {
                inherit username homeDirectory stateVersion;
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
          host = "macos";
          stateVersion = "25.11";
        };
        wsl = mkHome {
          system = "x86_64-linux";
          host = "wsl";
          wsl = true;
          stateVersion = "24.11";
        };
        ubuntu = mkHome {
          system = "x86_64-linux";
          host = "ubuntu";
          stateVersion = "24.11";
        };
      };
    in
    {
      # `<username>` points at the host named in machine.env, so `nh home switch`
      # and `home-manager switch` pick it without a `#name`.
      homeConfigurations =
        hosts
        // lib.optionalAttrs (env ? DOTFILES_USER && env ? DOTFILES_HOST) {
          ${env.DOTFILES_USER} = hosts.${env.DOTFILES_HOST};
        };
    };
}
