#!/bin/bash

# =============================================
# EmulOS Install Menu - Master Setup
# =============================================

DEPENDENCIES=("dialog" "curl" "sha256sum")

SCRIPT_URL="https://raw.githubusercontent.com/fg1998/emulOS/main/install_first.sh"
SCRIPT_PATH="$(realpath "$0")"

check_dependencies() {
    for prog in "${DEPENDENCIES[@]}"; do
        if ! command -v "$prog" &> /dev/null; then
            echo "Dependency '$prog' not found. Attempting to install..."
            apt update && apt install "$prog" -y
            if ! command -v "$prog" &> /dev/null; then
                echo "Failed to install '$prog'. Please install it manually."
                exit 1
            fi
        fi
    done
}

update_script() {
    TMP_FILE=$(mktemp)
    curl -s -L "$SCRIPT_URL" -o "$TMP_FILE"

    if [ ! -s "$TMP_FILE" ]; then
        dialog --msgbox "Failed to download the script from GitHub." 7 50
        rm -f "$TMP_FILE"
        return
    fi

    LOCAL_HASH=$(sha256sum "$SCRIPT_PATH" | awk '{print $1}')
    REMOTE_HASH=$(sha256sum "$TMP_FILE" | awk '{print $1}')

    if [[ "$LOCAL_HASH" == "$REMOTE_HASH" ]]; then
        dialog --msgbox "You already have the latest version of this script." 7 50
        rm -f "$TMP_FILE"
    else
        dialog --msgbox "Updating to the latest version of the script..." 7 50

        mv "$TMP_FILE" "$SCRIPT_PATH"
        chmod 777 "$SCRIPT_PATH"
        chown root:root "$SCRIPT_PATH"

        dialog --msgbox "Script updated successfully. Restarting..." 7 40
        exec "$SCRIPT_PATH"
    fi
}

# Submenu functions

run_configure_wifi() {
    ./configure_wifi.sh
}

run_install_dependencies() {
    ./install_dependencies.sh
}

run_download_emulators() {
    ./download_emulators.sh
}

run_download_bios() {
    ./download_bios.sh
}

run_download_emulos() {
    ./download_emulos.sh
}

run_set_emulos_autostart() {
    ./run_set_emulos_autostart.sh
}

# Only allow root
if [[ $EUID -ne 0 ]]; then
    echo "Please run this script as root: sudo $0"
    exit 1
fi

check_dependencies

main_menu() {
    while true; do
        OPTION=$(dialog --stdout --menu "EmulOS Installation Menu" 20 60 8 \
            0 "Update this script" \
            1 "Configure Wifi" \
            2 "Install dependencies" \
            3 "Download Emulators (Binary)" \
            4 "Download BIOS and ROMs" \
            5 "Download emulOS Front end" \
            6 "Set emulOS to run on OS start" \
            7 "Exit")

        case $OPTION in
            0) update_script ;;
            1) run_configure_wifi ;;
            2) run_install_dependencies ;;
            3) run_download_emulators ;;
            4) run_download_bios ;;
            5) run_download_emulos ;;
            6) run_set_emulos_autostart ;;
            7) clear; exit 0 ;;
            *) clear; exit 0 ;;
        esac
    done
}

main_menu
