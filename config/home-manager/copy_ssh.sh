#!/bin/bash

WINDOWS_USER=$(/mnt/c/Windows/System32/cmd.exe "/c" "echo %USERNAME%" 2>/dev/null | tr -d '\r')
SOURCE="/mnt/c/Users/${WINDOWS_USER}/.ssh"
DEST="$HOME/.ssh"

if [ -d "$SOURCE" ]; then
  echo "Found folder: $SOURCE"

  mkdir -p "$DEST"

  cp -r "$SOURCE"/* "$DEST"
  chmod -R 700 "$DEST"/*
  echo "Set permissions to 600 for all keys in $DEST"

  echo "Contents of $SOURCE copied to $DEST"
else
  echo "HIII"
  echo $WINDOWS_USER
  echo "Folder $SOURCE does not exist. Nothing to copy."
fi
