#!/bin/bash

echo "Refreshing home-manager configuration..."

SOURCE="/home/zaidb/dotfiles/config/home-manager"
DEST="$HOME/.config/home-manager"

if [ ! -d "$SOURCE" ]; then
  echo "Error: Source directory ($SOURCE) does not exist!"
  exit 1
fi

if [ -d "$DEST" ]; then
  echo "Removing existing home-manager configuration..."
  rm -rf "$DEST" || {
    echo "Failed to remove existing directory $DEST. Aborting."
    exit 1
  }
fi

echo "Copying files from $SOURCE to $DEST..."
cp -R "$SOURCE" "$DEST" || {
  echo "Failed to copy files to $DEST. Aborting."
  exit 1
}

echo "Applying new home-manager configuration..."
home-manager switch --flake "$DEST#zaidb-wsl" || {
  echo "Home-manager switch failed. Check the output above for details."
  exit 1
}

echo "Home-manager configuration updated successfully!"
