#!/bin/bash

# .deb package URL
DEB_URL="https://github.com/fg1998/emulOS/releases/download/0.0.1/emulos_0.0.1_armhf.deb"
DEB_FILE="emulos_0.0.1_armhf.deb"

echo "Downloading EmulOS package..."
curl -L -o "$DEB_FILE" "$DEB_URL"

if [ $? -ne 0 ]; then
  echo "Error downloading the file."
  exit 1
fi

echo "Installing the package..."
sudo dpkg -i "$DEB_FILE"

if [ $? -ne 0 ]; then
  echo "There were issues during installation. Attempting to fix dependencies..."
  sudo apt-get install -f -y
fi

echo "Installation complete."
