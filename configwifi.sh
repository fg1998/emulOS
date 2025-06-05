#!/bin/bash

# =============================================
# Ultimate Wi-Fi Setup - RetroPie Style (EN)
# =============================================

# Dependencies required
DEPENDENCIES=("dialog" "iw" "nmtui")

# Check dependencies
check_dependencies() {
    for prog in "${DEPENDENCIES[@]}"; do
        if ! command -v "$prog" &> /dev/null; then
            echo "Error: '$prog' is not installed."
            echo "Please install it using: sudo apt install $prog"
            exit 1
        fi
    done
}

# Get current Wi-Fi region
get_current_region() {
    iw reg get | grep country | awk '{print $2}' | cut -d':' -f1
}

# Wi-Fi region selection menu
choose_region() {
    REGION=$(dialog --stdout --menu "Select your Wi-Fi Region" 20 50 15 \
        "BR" "Brazil" \
        "US" "United States" \
        "EU" "Europe" \
        "JP" "Japan" \
        "CN" "China" \
        "RU" "Russia" \
        "IN" "India" \
        "KR" "South Korea" \
        "ZA" "South Africa" \
        "AU" "Australia" \
        "GB" "United Kingdom" \
        "AR" "Argentina")

    if [ -n "$REGION" ]; then
        sudo iw reg set "$REGION"
        sleep 1
    else
        dialog --msgbox "No region selected. Operation canceled." 8 50
    fi
}

# Launch nmtui
start_nmtui() {
    sudo nmtui
}

# Header (RetroPie style)
show_header() {
    dialog --title "Wi-Fi Setup" --msgbox "Welcome to the Setup Assistant\nRetroPie Style :)" 8 50
}

# Main Menu
main_menu() {
    while true; do
        CURRENT_REGION=$(get_current_region)
        if [ -z "$CURRENT_REGION" ] || [ "$CURRENT_REGION" == "00" ]; then
            REGION_STATUS="Not configured"
        else
            REGION_STATUS="$CURRENT_REGION"
        fi

        OPTION=$(dialog --stdout --menu "Current Wi-Fi Region
