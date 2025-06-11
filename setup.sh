#!/bin/bash

# Check if the script is being run with sudo
if [ "$EUID" -ne 0 ]; then
    echo "This script needs to be run with sudo to ensure correct permissions."
    echo "Please execute: sudo ./download_emulos.sh"
    exit 1
fi

# Determine the home directory of the user who invoked sudo
# If SUDO_USER is not defined (e.g., if run directly as root),
# it will use the current user's home (root in this case).
if [ -n "$SUDO_USER" ]; then
    USER_HOME=$(eval echo "~$SUDO_USER")
else
    USER_HOME="$HOME" # Typically /root if executed directly as root
fi

DOWNLOAD_DIR="$USER_HOME/emulOS_scripts"

# List of URLs for the scripts to download
SCRIPT_URLS=(
    "https://raw.githubusercontent.com/fg1998/emulOS/main/install_first.sh"
    "https://raw.githubusercontent.com/fg1998/emulOS/main/configure_wifi.sh"
    "https://raw.githubusercontent.com/fg1998/emulOS/main/download_emulators.sh"
    "https://raw.githubusercontent.com/fg1998/emulOS/main/download_bios.sh"
    "https://raw.githubusercontent.com/fg1998/emulOS/main/install_dependencies.sh"
    "https://raw.githubusercontent.com/fg1998/emulOS/main/download_emulos.sh"
)

echo "Creating download directory in $SUDO_USER's home: $DOWNLOAD_DIR"
mkdir -p "$DOWNLOAD_DIR"

# Set ownership of the directory to the user who invoked sudo
# This ensures the user who called sudo has full control over the folder.
if [ -n "$SUDO_USER" ]; then
    chown -R "$SUDO_USER":"$(id -gn "$SUDO_USER")" "$DOWNLOAD_DIR"
fi

echo "Downloading scripts..."
for url in "${SCRIPT_URLS[@]}"; do
    filename=$(basename "$url")
    echo "Downloading $filename..."
    curl -sSL "$url" -o "$DOWNLOAD_DIR/$filename"
    if [ $? -ne 0 ]; then
        echo "Error downloading $filename. Aborting."
        exit 1
    fi
done

echo "Granting execution permissions to scripts..."
chmod +x "$DOWNLOAD_DIR"/*.sh

# Set ownership of the files to the user who invoked sudo
if [ -n "$SUDO_USER" ]; then
    chown -R "$SUDO_USER":"$(id -gn "$SUDO_USER")" "$DOWNLOAD_DIR"/*.sh
fi

echo "Scripts downloaded and permissions granted. Now executing install_first.sh..."
# Execute install_first.sh script as the user who invoked sudo
# This is important so install_first.sh doesn't accidentally create files as root in the user's home
if [ -n "$SUDO_USER" ]; then
    sudo -u "$SUDO_USER" "$DOWNLOAD_DIR/install_first.sh"
else
    # If SUDO_USER is not defined (rare, but possible), execute as root
    "$DOWNLOAD_DIR/install_first.sh"
fi

echo "Process complete."