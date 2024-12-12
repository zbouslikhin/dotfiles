# WSL Setup Guide

## Step 1: Update WSL
```bash
wsl --update
```

## Step 2: Install Ubuntu
```bash
wsl --install
```

## Step 3: Install Development Dependencies
Run the following command to install essential development tools and libraries:
```bash
sudo apt update && sudo apt install -y \
    build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev \
    curl git libncursesw5-dev xz-utils tk-dev \
    libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
```

## Step 4: Install Nix
Install Nix with the following command:
```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

### Test Nix Installation
Verify that Nix is installed correctly:
```bash
nix-shell -p nix-info --run "nix-info -m"
```

## Step 5: Configure SSH
Copy your SSH keys from Windows:
```bash
cp -R /mnt/c/Users/<YourWindowsUsername>/.ssh/ ~/.ssh
```
Replace `<YourWindowsUsername>` with your actual Windows username.

## Step 6: Clone Dotfiles Repository
Change to your home directory:
```bash
git clone git@github.com:zbouslikhin/dotfiles.git ~/
```

## Step 7: Copy Dotfiles
Copy the configuration files:
```bash
cp -R dotfiles/config/ ~/.config
```

## Step 8: Copy Configuration Files
Copy the Home Manager configuration:
```bash
cp -R /home/zaidb/dotfiles/config/home-manager ~/.config/home-manager
```
Copy the Nix configuration:
```bash
cp -R /home/zaidb/dotfiles/config/nix ~/.config/nix
```

## Step 9: Update Nix Channels
Update Nix channels:
```bash
nix-channel --update
```

## Step 10: Install Home Manager
Install Home Manager with the following command:
```bash
nix-env -iA nixpkgs.home-manager
```

## Step 11: Activate Home Manager as a Flake
Activate Home Manager using the Flake configuration:
```bash
home-manager switch --flake ~/.config/home-manager#zaidb-wsl
```

## Step 12: Set Zsh as Default Shell
Set Zsh as your default shell:
```bash
chsh -s /home/zaidb/.nix-profile/bin/zsh
```

