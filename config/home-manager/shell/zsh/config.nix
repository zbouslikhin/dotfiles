{ config, pkgs, username, ... }:

{
    home.packages = [
        pkgs.zsh
        pkgs.zsh-vi-mode
    ];


    programs.zsh = {
        enable = true;
        autosuggestion.enable = true;
        enableCompletion = true;

        initExtra = ''
          source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
        '';

        oh-my-zsh = {
            enable = true;
            plugins = [
                "sudo"
            ];
        };

        shellAliases = {
            hm-build = "source /home/zaidb/dotfiles/config/home-manager/shell/zsh/refresh_hm.sh";
            hm-clean = "nix-collect-garbage --delete-old";
            ls = "exa --long --header --icons";
            lsa = "ls --all";
            ff = "fzf";
        };

        plugins = [
            {
                name = "fzf-tab";
                src = pkgs.fetchFromGitHub {
                owner = "Aloxaf";
                repo = "fzf-tab";
                rev = "190500bf1de6a89416e2a74470d3b5cceab102ba";
                sha256 = "1dipsy0s67fr47ig5559bcp1h5yn8rdjshhs8zsq7j8plvvh99qb";
                };
            }
            {
                name = "zsh-history-substring-search";
                src = pkgs.fetchFromGitHub {
                    owner = "zsh-users";
                    repo = "zsh-history-substring-search";
                    rev = "47a7d416c652a109f6e8856081abc042b50125f4";
                    sha256 = "1mvilqivq0qlsvx2rqn6xkxyf9yf4wj8r85qrxizkf0biyzyy4hl";
                };
            }

            {
                name = "zsh-syntax-highlighting";
                src = pkgs.fetchFromGitHub {
                    owner = "zsh-users";
                    repo = "zsh-syntax-highlighting";
                    rev = "db6cac391bee957c20ff3175b2f03c4817253e60";
                    sha256 = "0d9nf3aljqmpz2kjarsrb5nv4rjy8jnrkqdlalwm2299jklbsnmw";
                };
            }
        ];
    };
}
