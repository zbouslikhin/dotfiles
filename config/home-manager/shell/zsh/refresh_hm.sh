#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

echo ""
echo -e "${BLUE}Refreshing home-manager configuration...${RESET}"

SOURCE="/Users/zaidb/Documents/dotfiles/config/home-manager"
DEST="$HOME/.config/home-manager"

if [ ! -d "$SOURCE" ]; then
  echo -e "${RED}Error: Source directory ($SOURCE) does not exist!${RESET}"
fi

if [ -d "$DEST" ]; then
  echo -e "${BLUE}Removing existing home-manager configuration...${RESET}"
  rm -rf "$DEST" || {
    echo -e "${RED}Failed to remove existing directory $DEST. Aborting.${RESET}"
  }
fi

echo -e "${BLUE}Copying files from $SOURCE to $DEST...${RESET}"
cp -R "$SOURCE" "$DEST" || {
  echo -e "${RED}Failed to copy files to $DEST. Aborting.${RESET}"
}

echo -e "${BLUE}Applying new home-manager configuration...${RESET}"
echo ""
home-manager switch --flake "$DEST#zaidb-macos" || {
  echo -e "${RED}Home-manager switch failed. Check the output above for details.${RESET}"
}

echo -e "${GREEN}Home-manager configuration updated successfully!${RESET}"
