#!/bin/bash

# =============================================
# EmulOS Wi-Fi Setup - Final Production Edition
# =============================================

DEPENDENCIES=("dialog" "iw" "nmtui" "rfkill")

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

# Restart Wi-Fi interface after region change
restart_wifi() {
    sudo rfkill block wifi
    sleep 1
    sudo rfkill unblock wifi
    sleep 1
}

# Save region permanently
save_region_permanently() {
    sudo sed -i '/^REGDOMAIN=/d' /etc/default/crda 2>/dev/null
    echo "REGDOMAIN=$1" | sudo tee -a /etc/default/crda >/dev/null
}

# Wi-Fi region selection menu
choose_region() {
    REGION=$(dialog --stdout --menu "Select your Wi-Fi Region" 22 60 20 \
        "US" "United States" \
        "CA" "Canada" \
        "BR" "Brazil" \
        "AR" "Argentina" \
        "MX" "Mexico" \
        "GB" "United Kingdom" \
        "DE" "Germany" \
        "FR" "France" \
        "ES" "Spain" \
        "IT" "Italy" \
        "RU" "Russia" \
        "CN" "China" \
        "JP" "Japan" \
        "KR" "South Korea" \
        "IN" "India" \
        "AU" "Australia" \
        "ZA" "South Africa" \
        "NZ" "New Zealand" \
        "EU" "Europe (General)")

    if [ -n "$REGION" ]; then
        sudo iw reg set "$REGION"
        restart_wifi

        dialog --yesno "Do you want to save this region permanently for future boots?" 8 50
        if [ $? -eq 0 ]; then
            save_region_permanently "$REGION"
            dialog --msgbox "Region saved permanently!" 6 40
        fi

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
    dialog --title "Wi-Fi Setup" --msgbox "Welcome to the Wi-Fi Setup Assistant\nEmulOS Production Edition" 8 50
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

        OPTION=$(dialog --stdout --menu "Current Wi-Fi Region: $REGION_STATUS" 15 60 6 \
            1 "Set Wi-Fi Region" \
            2 "Configure Wi-Fi (nmtui)" \
            3 "Exit")

        case $OPTION in
            1) choose_region ;;
            2) start_nmtui ;;
            3) clear; exit 0 ;;
            *) break ;;
        esac
    done
}

# MAIN
clear
check_dependencies
show_header
main_menu
