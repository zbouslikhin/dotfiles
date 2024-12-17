{ config, pkgs, ... }:

{
    home.packages = [
        pkgs.asdf-vm
        # pkgs.awscli
        # pkgs.nh
        # pkgs.pkg-config
    ];
    programs.nh = {
    enable = true;
    # clean.enable = true;
    # clean.extraArgs = "--keep-since 4d --keep 3";
    # flake = "/home/user/my-nixos-config";
  };

#     programs = {
#         zsh = {
#             initExtra = ". $HOME/.nix-profile/share/asdf-vm/asdf.sh";
#         };
#     };  
}
