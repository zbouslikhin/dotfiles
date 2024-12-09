# For WSL
- in home, `git clone git@github.com:zbouslikhin/dotfiles.git`
- ln -s /home/zaidb/dotfiles/config/home-manager home-manager/ 
- home-manager switch --flake .#zaidb-ws
- nix-channel --update
- nix-env -iA nixpkgs.home-manager