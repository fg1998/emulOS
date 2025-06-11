#!/bin/bash

# =============================================
# EmulOS Install Menu - Master Setup
# =============================================

DEPENDENCIES=("dialog")

# Check dependencies
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

# Allow root only (since the subscripts will require sudo)
if [[ $EUID -ne 0 ]]; then
    echo "Please run this script as root: sudo $0"
    exit 1
fi

# First check for dependencies
check_dependencies

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

# Main menu
main_menu() {
    while true; do
        OPTION=$(dialog --stdout --menu "EmulOS Installation Menu" 15 60 5 \
            1 "Configure Wifi" \
            2 "Install dependencies" \
            3 "Download Emulators (Binary)" \
            4 "Download BIOS and ROMs" \
            5 "Download emulOS Front end"
            6 "Exit")

        case $OPTION in
            1) run_configure_wifi ;;
            2) run_install_dependencies ;;
            3) run_download_emulators ;;
            4) run_download_bios ;;
            5) run_download_emulos ;;
            6) clear; exit 0 ;;
            *) clear; exit 0 ;;
        esac
    done
}

main_menu
