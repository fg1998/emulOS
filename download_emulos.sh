#!/bin/bash
set -e

# Dependencies
DEPENDENCIES=("curl" "dialog" "dpkg-deb")

# Check dependencies
for prog in "${DEPENDENCIES[@]}"; do
  if ! command -v "$prog" &> /dev/null; then
    echo "Error: '$prog' is not installed. Please install it using: sudo apt-get install -y $prog"
    exit 1
  fi
done

# Target directory
APP_DIR="$HOME/emulos-app"
mkdir -p "$APP_DIR"

# Initial dialog
dialog --title "EmulOS Installer" --msgbox "This installer will download and install the latest version of EmulOS into the ~/emulos-app folder. Existing user data (like DATA folder and *.json files) will be preserved." 10 60

# Get latest .deb release URL from GitHub
dialog --infobox "Checking for the latest EmulOS release..." 5 60
DEB_URL=$(curl -s https://api.github.com/repos/fg1998/emulOS/releases/latest | grep "browser_download_url" | grep "armhf.deb" | cut -d '"' -f 4)

if [ -z "$DEB_URL" ]; then
  dialog --msgbox "Error: Could not find a .deb release on GitHub." 8 60
  exit 1
fi

# File name
DEB_FILE="${DEB_URL##*/}"
TMP_DIR="$(mktemp -d)"
cd "$TMP_DIR"

# Download .deb file
dialog --infobox "Downloading $DEB_FILE..." 5 60
curl -L "$DEB_URL" -o "$DEB_FILE"

# Extract only data portion to preserve user content
dialog --infobox "Installing EmulOS into $APP_DIR..." 5 60
dpkg-deb -x "$DEB_FILE" "$APP_DIR"

# Clean up
rm -f "$DEB_FILE"
cd /
rm -rf "$TMP_DIR"

# Final message
dialog --title "Installation Complete" --msgbox "EmulOS was successfully installed to $APP_DIR.\n\nYou can now run it from there." 10 60