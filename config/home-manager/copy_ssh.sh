#!/bin/bash

SOURCE="/mnt/c/Users/zaid/.ssh"
DEST="$HOME/.ssh"

if [ -d "$SOURCE" ]; then
  echo "Found folder: $SOURCE"

  mkdir -p "$DEST"

  cp -r "$SOURCE"/* "$DEST"
  chmod -R 700 "$DEST"/*
  echo "Set permissions to 600 for all keys in $DEST"

  echo "Contents of $SOURCE copied to $DEST"
else
  echo "Folder $SOURCE does not exist. Nothing to copy."
fi
