#!/bin/bash

# Destination folder for all result directories
DEST_FOLDER="taurus-result"

# Create the destination if it doesn't exist
mkdir -p "$DEST_FOLDER"

# Find all timestamped Taurus result folders (starts with a date)
FOLDERS=$(find . -maxdepth 1 -type d -name "202*" ! -path "./$DEST_FOLDER")

# Check and move each folder
if [ -z "$FOLDERS" ]; then
  echo "⚠️ No timestamped Taurus result folders found."
else
  echo "📦 Moving folders to $DEST_FOLDER/ ..."
  for DIR in $FOLDERS; do
    echo "  ➤ Moving $DIR"
    mv "$DIR" "$DEST_FOLDER/"
  done
  echo "✅ All folders moved successfully."
fi
