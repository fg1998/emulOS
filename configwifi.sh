#!/bin/bash

# =============================================
# EmulOS Wi-Fi Setup - Headless Raspberry Pi OS Compatible
# =============================================

WPA_CONF="/etc/wpa_supplicant/wpa_supplicant.conf"
INTERFACE="wlan0"
DEPENDENCIES=("dialog" "iwlist" "wpa_cli")

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

# Allow root only
if [[ $EUID -ne 0 ]]; then
    echo "Please run this script as root: sudo $0"
    exit 1
fi

# Region selection
choose_country() {
    COUNTRY=$(dialog --stdout --menu "Select your Wi-Fi country code" 20 50 20 \
        "US" "United States" \
        "BR" "Brazil" \
        "CA" "Canada" \
        "GB" "United Kingdom" \
        "DE" "Germany" \
        "FR" "France" \
        "ES" "Spain" \
        "IT" "Italy" \
        "IN" "India" \
        "JP" "Japan" \
        "KR" "South Korea" \
        "CN" "China" \
        "RU" "Russia" \
        "AU" "Australia" \
        "NZ" "New Zealand" \
        "ZA" "South Africa" \
        "AR" "Argentina" \
        "EU" "Europe")

    if [ -z "$COUNTRY" ]; then
        dialog --msgbox "No country selected. Exiting." 6 40
        clear
        exit 1
    fi
}

# Scan available networks
scan_networks() {
    dialog --infobox "Scanning for Wi-Fi networks..." 3 40
    sleep 2
    SSIDS=$(iwlist $INTERFACE scan | grep ESSID | cut -d '"' -f2 | sort | uniq)
    
    # Create menu list
    MENU_ITEMS=()
    while IFS= read -r ssid; do
        if [ -n "$ssid" ]; then
            MENU_ITEMS+=("$ssid" "")
        fi
    done <<< "$SSIDS"

    if [ ${#MENU_ITEMS[@]} -eq 0 ]; then
        dialog --msgbox "No Wi-Fi networks found. Exiting." 6 40
        clear
        exit 1
    fi

    SSID=$(dialog --stdout --menu "Select your Wi-Fi network" 20 60 15 "${MENU_ITEMS[@]}")
    
    if [ -z "$SSID" ]; then
        dialog --msgbox "No network selected. Exiting." 6 40
        clear
        exit 1
    fi
}

# Ask for Wi-Fi password
ask_password() {
    PSK=$(dialog --stdout --insecure --passwordbox "Enter Wi-Fi password for $SSID:" 10 50)
    if [ -z "$PSK" ]; then
        dialog --msgbox "No password entered. Exiting." 6 40
        clear
        exit 1
    fi
}

# Write configuration
write_config() {
    cat > "$WPA_CONF" <<EOF
country=$COUNTRY
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
    ssid="$SSID"
    psk="$PSK"
}
EOF
}

# Restart Wi-Fi
restart_wifi() {
    wpa_cli -i $INTERFACE reconfigure
    sleep 3
}

# MAIN
clear
check_dependencies

choose_country
scan_networks
ask_password
write_config

restart_wifi

dialog --msgbox "Wi-Fi configured successfully!" 6 40
clear
exit 0
