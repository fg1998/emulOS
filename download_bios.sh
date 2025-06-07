#!/bin/bash

# =============================================
# EmulOS BiosInstaller 
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
dialog --title "Download BIOS and ROMS" --msgbox "The bios folder contains files needed for some emulators to work properly. These include ROMs, operating systems, disk images, and hard drive images. Without them, some systems may not run correctly or may not start at all.

Many of these files are available online because they are either public domain, shared by original rights holders, or from companies that no longer exist. However, some files may still be under copyright, or their legal status may be uncertain. In some cases, you may need to own the original hardware or a legal copy of the BIOS or system you want to emulate.

EmulOS does not include any of these files by default. You’ll need to download them yourself or create dumps from your own hardware if possible.

When you're ready, you can download these files (if available) by entering a WGET, CURL, or similar command in the text box next dialog." 20 90


# Defalt Command
DEFAULT_COMMAND="curl -L https://archive.org/download/emulators-latest/bios-20250607.tar.gz -o \"$USER_HOME/bios.tar.gz\""

# Uer input command
COMMAND=$(dialog --inputbox "Enter the download command (WGET, CURL or similar):" 10 100 "$DEFAULT_COMMAND" 3>&1 1>&2 2>&3 3>&-)

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
DOWNLOADED_FILE="$USER_HOME/bios.tar.gz"
if [ ! -f "$DOWNLOADED_FILE" ]; then
    echo "Download failed: file not found at $DOWNLOADED_FILE"
    dialog --msgbox "Error: Download failed. File not found. $DOWNLOADED_FILE" 10 50
    exit 1
fi

echo "Extracting files..."

echo "$DOWNLOADED_FILE"
echo "$USER_HOME/emulators"
tar -xzvf "$DOWNLOADED_FILE" -C "$USER_HOME"

echo "Cleaning up..."
rm -f "$DOWNLOADED_FILE"

chmod -R a+rw "$USER_HOME/emulators"

# Final message
dialog --msgbox "Emulator binaries have been successfully installed!" 10 50
clear
