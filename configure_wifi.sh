#!/bin/bash

# --- Initial Checks ---
echo "DEBUG: Running initial checks..."
if [ "$(id -u)" -ne 0 ]; then
  echo "ERROR: This script needs to be run with root privileges." >&2
  echo "Please run with 'sudo ./your-script.sh'" >&2
  exit 1
fi

for cmd in dialog raspi-config nmcli; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "ERROR: The tool '$cmd' was not found." >&2
    if [ "$cmd" == "nmcli" ]; then
        echo "NetworkManager might not be installed. Try 'sudo apt update && sudo apt install network-manager'" >&2
    elif [ "$cmd" == "dialog" ]; then
        echo "The 'dialog' tool is not installed. Try 'sudo apt update && sudo apt install dialog'" >&2
    elif [ "$cmd" == "raspi-config" ]; then
        echo "The 'raspi-config' tool is not found. Ensure you are on Raspberry Pi OS." >&2
    fi
    exit 1
  fi
done
echo "DEBUG: All required commands found."


# --- 1. Country Configuration ---

ISO3166_FILE="/usr/share/zoneinfo/iso3166.tab"

if [ ! -f "$ISO3166_FILE" ]; then
    dialog --title "Critical Error" --msgbox "Country file not found: '$ISO3166_FILE'." 8 50
    exit 1
fi

# Geração da lista de países
COUNTRY_LIST=$(awk -F'\t' '!/^#/ {print $1, "\""$2"\""}' "$ISO3166_FILE" 2>&1)
AWK_STATUS=$?


if [ $AWK_STATUS -ne 0 ]; then
    dialog --title "Error" --msgbox "Failed to generate country list (awk error). Output: $COUNTRY_LIST" 12 70
    exit 1
fi

if [ -z "$(echo "$COUNTRY_LIST" | tr -d ' ')" ]; then
    echo "DEBUG: COUNTRY_LIST is empty after awk processing. This is a problem."
    dialog --title "Error" --msgbox "Failed to generate country list. It appears empty. Check '$ISO3166_FILE'." 8 60
    exit 1
fi

echo "DEBUG: COUNTRY_LIST content (first 200 chars for dialog): ${COUNTRY_LIST:0:200}"

dialog --title "EmulOS Wi-Fi Network Configurator" \
       --msgbox "\nFirst, let's configure the Wi-Fi regulatory domain by selecting your country." 8 70

DIALOG_COMMAND="dialog --title \"Country Selection\" --menu \"\nPlease select your country from the list.\" 20 70 15 ${COUNTRY_LIST} 2>&1 >/dev/tty"
echo "$DIALOG_COMMAND" | head -n 5

SELECTED_COUNTRY=$(eval $DIALOG_COMMAND)

EXIT_STATUS_DIALOG=$?


if [ $EXIT_STATUS_DIALOG -ne 0 ] || [ -z "$SELECTED_COUNTRY" ]; then
    clear
    echo "Operation cancelled or no country selected from dialog."
    exit 0
fi

dialog --infobox "\nConfiguring Wi-Fi country to '${SELECTED_COUNTRY}'..." 5 50
raspi-config nonint do_wifi_country "$SELECTED_COUNTRY" > /dev/null 2>&1
sleep 1

# --- 2. Scan and Select Wi-Fi Network ---

dialog --title "EmulOS Wi-Fi Network Configurator" \
       --infobox "\nScanning for available Wi-Fi networks... Please wait." 5 60
sleep 2 # Give time for the radio interface to initialize with the new country

RAW_NMCLI_OUTPUT=$(nmcli --terse --fields SSID,SECURITY,SIGNAL dev wifi list --rescan yes 2>&1)
NMCLI_RAW_STATUS=$?

echo "$RAW_NMCLI_OUTPUT"

if [ $NMCLI_RAW_STATUS -ne 0 ]; then
    dialog --title "Error" --msgbox "nmcli command failed. Output: $RAW_NMCLI_OUTPUT" 12 70
    clear
    exit 1
fi

WIFI_LIST=$(echo "$RAW_NMCLI_OUTPUT" | awk -F: '
  $1 && $2 {
    gsub(/"/, "", $1);
    gsub(/"/, "", $2);
    printf "\"%s\" \"%s | Signal: %s%%\" ", $1, $2, $3
  }
' 2>&1)
AWK_WIFI_STATUS=$?


if [ $AWK_WIFI_STATUS -ne 0 ]; then
    dialog --title "Error" --msgbox "Failed to format Wi-Fi list (awk error). Output: $WIFI_LIST" 12 70
    clear
    exit 1
fi

if [ -z "$(echo "$WIFI_LIST" | tr -d ' ')" ]; then
    dialog --title "Error" --msgbox "\nNo Wi-Fi networks found! Check if your antenna is connected and if you are within range of a network." 8 60
    clear
    exit 1
fi

DIALOG_WIFI_COMMAND="dialog --title \"\nWi-Fi Network Selection\" --menu \"Select the network you want to connect to.\" 20 70 15 ${WIFI_LIST} 2>&1 >/dev/tty"

SELECTED_SSID=$(eval $DIALOG_WIFI_COMMAND)

EXIT_STATUS_DIALOG_SSID=$?


if [ $EXIT_STATUS_DIALOG_SSID -ne 0 ] || [ -z "$SELECTED_SSID" ]; then
    clear
    echo "Operation cancelled from SSID selection."
    exit 0
fi

# --- 3. Enter Password and Connect ---

#dialog --title "Wi-Fi Network Configurator (Step 3 of 3)" \
#       --msgbox "You selected the network: ${SELECTED_SSID}.\n\nPlease enter the password." 8 70

WIFI_PASSWORD=$(dialog --title "Network Password" \
                       --inputbox "\nPlease enter the password for network '${SELECTED_SSID}':" \
                       10 70 \
                       2>&1 >/dev/tty)

EXIT_STATUS_DIALOG_PASS=$?


if [ $EXIT_STATUS_DIALOG_PASS -ne 0 ]; then
    clear && echo "Operation cancelled." && exit 0
fi

dialog --title "Connecting..." --infobox "\nAttempting to connect to network '${SELECTED_SSID}'..." 5 60

# Attempt to connect and capture the result
CONNECTION_RESULT=$(nmcli dev wifi connect "$SELECTED_SSID" password "$WIFI_PASSWORD" 2>&1)
CONNECTION_STATUS=$?

# --- Finalization ---
if [ $CONNECTION_STATUS -eq 0 ]; then
    dialog --title "Success!" --msgbox "\nSuccessfully connected to network '${SELECTED_SSID}'!" 8 60
else
    dialog --title "Connection Failed" \
           --msgbox "\nCould not connect.\n\nPlease verify the password and try again.\n\nError reported: ${CONNECTION_RESULT}" 12 70
fi

clear
echo "Network configuration process finished."
# Check connection status
#ip addr show wlan0
echo "To test the connection: ping -c 4 8.8.8.8"
