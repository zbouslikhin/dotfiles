#!/bin/bash

echo "Refresh"

SOURCE="/home/zaidb/dotfiles/config/home-manager"
DEST="$HOME/.config/home-manager/"

rm -r $DEST
cp -R $SOURCE $DEST
echo "Home-manager config updated from Dotfiles repo!"
home-manager switch --flake ~/.config/home-manager#zaidb-wsl
