#!/bin/bash

# =============================================
# EmulOS Emulator Binary Installer 
# =============================================

set -e

# Dependencies List
DEPENDENCIES=("dialog" "curl")

# Dependencies
for prog in "${DEPENDENCIES[@]}"; do
    if ! command -v "$prog" &> /dev/null; then
        echo "Error: '$prog' is not installed. Please install it using: sudo apt-get install -y $prog"
        exit 1
    fi
done

# user home, even when SUDO
USER_HOME=$(eval echo ~$(logname))

#Create emulators folder
mkdir -p "$USER_HOME/emulators"

# Initial message
dialog --msgbox "This script will install the emulator binaries used by EmulOS.\n\nYou will be prompted to enter the command to download the package. The default value is pre-filled, but you can modify it if needed.\n\nPress OK to continue." 15 60

# Defalt Command
DEFAULT_COMMAND="curl -L https://archive.org/download/emulators-09062025/emulators.tar.gz -o \"$USER_HOME/emulators.tar.gz\""

# Uer input command
COMMAND=$(dialog --inputbox "Enter the command to download the emulator binaries:" 10 100 "$DEFAULT_COMMAND" 3>&1 1>&2 2>&3 3>&-)
DIALOG_EXIT_CODE=$?

# On ESC or Cancel
if [ $DIALOG_EXIT_CODE -ne 0 ]; then
    dialog --msgbox "Operation cancelled by user." 8 40
    clear
    exit 1
fi


clear

# TRIM and remove line breaks at end
COMMAND=$(echo "$COMMAND" | tr -d '\r\n')

echo "Running download command..."
bash -c "$COMMAND"

# Verify if file has been downloades
DOWNLOADED_FILE="$USER_HOME/emulators.tar.gz"
if [ ! -f "$DOWNLOADED_FILE" ]; then
    echo "Download failed: file not found at $DOWNLOADED_FILE"
    dialog --msgbox "Error: Download failed. File not found. $DOWNLOADED_FILE" 10 50
    exit 1
fi

echo "Extracting files..."

echo "$DOWNLOADED_FILE"
echo "$USER_HOME/emulators"
#tar -xzvf "$DOWNLOADED_FILE" -C "$USER_HOME/emulators"
tar -xzvf "$DOWNLOADED_FILE" -C "$USER_HOME"

echo "Cleaning up..."
rm -f "$DOWNLOADED_FILE"

#chmod -R a+rw "$USER_HOME/emulators"

# Final message
dialog --msgbox "Emulator binaries have been successfully installed!" 10 50
clear
