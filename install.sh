

### --- BEGIN install.sh --- ###
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
    ./download_emulos.sh"
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

### --- END install.sh --- ###


### --- BEGIN install_dependencies.sh --- ###
#!/bin/bash

LOGFILE="/tmp/emulos-install.log"
exec > >(tee -a "$LOGFILE") 2>&1

set -e

# Função para exibir mensagem de erro e mostrar o log
error_handler() {
    dialog --title "Installation Error" --textbox "$LOGFILE" 30 80
    exit 1
}

trap error_handler ERR

# Atualiza o sistema
sudo apt-get update -y

# Instala o mínimo necessário do X e openbox
sudo apt-get install --no-install-recommends \
  xserver-xorg \
  xinit \
  openbox \
  xterm \
  fonts-dejavu-core \
  gpicview \
  x11-utils \
  x11-xserver-utils \
  xclip \
  gpm \
  dialog \
  curl \
  -y

# Configura o xinitrc
cat > ~/.xinitrc << 'EOF'
#!/bin/sh

# Ajuste de DPI para o Pi400, melhora o xterm e fontes
xrdb -merge <<EOD
Xft.dpi: 96
XTerm*faceName: DejaVu Sans Mono
XTerm*faceSize: 12
EOD

xterm &
exec openbox
EOF

chmod +x ~/.xinitrc

# Python e gdown para downloads
sudo apt-get install python3 python3-pip -y
python3 -m pip install --break-system-packages --user gdown

# Ajusta o PATH caso ~/.local/bin não esteja
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc
  export PATH=$PATH:$HOME/.local/bin
fi

# Faz o download dos binários compactados (substitua pelo ID correto)
gdown -id 1Ooj-wX8HZBU3yDXbs338Wya9_fVqO_2w

# Descompacta para o sistema
sudo tar -xvzf /home/emulos/emulators.tar.gz -C / --strip-components=1

# Instala bibliotecas runtime necessárias para os binários rodarem (Electron + emuladores)
sudo apt-get install \
  libatk-bridge2.0-0 \
  libgtk-3-0 \
  libnss3 \
  libxss1 \
  libasound2 \
  libdrm2 \
  libxrandr2 \
  libxcomposite1 \
  libxdamage1 \
  libxfixes3 \
  libxcb-dri3-0 \
  libgbm1 \
  libxkbcommon0 \
  libxkbcommon-x11-0 \
  alsa-utils alsa-oss \
  systemd systemd-sysv pulseaudio \
  -y

# Inicia o pulseaudio (precisa para alguns emuladores)
systemctl --user start pulseaudio

# Mensagem final de sucesso
dialog --title "Installation Complete" --msgbox "The EmulOS environment has been successfully installed!" 8 50

exit 0

### --- END install_dependencies.sh --- ###


### --- BEGIN download_emulators.sh --- ###
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

### --- END download_emulators.sh --- ###


### --- BEGIN download_bios.sh --- ###
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
DEFAULT_COMMAND="curl -L https://archive.org/download/bios-09062025.tar.gz -o \"$USER_HOME/bios.tar.gz\""

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

### --- END download_bios.sh --- ###


### --- BEGIN download_emulos.sh --- ###
#!/bin/bash

# .deb package URL
DEB_URL="https://github.com/fg1998/emulOS/releases/download/0.0.1/emulos_0.0.1_armhf.deb"
DEB_FILE="emulos_0.0.1_armhf.deb"

echo "Downloading EmulOS package..."
curl -L -o "$DEB_FILE" "$DEB_URL"

if [ $? -ne 0 ]; then
  echo "Error downloading the file."
  exit 1
fi

echo "Installing the package..."
sudo dpkg -i "$DEB_FILE"

if [ $? -ne 0 ]; then
  echo "There were issues during installation. Attempting to fix dependencies..."
  sudo apt-get install -f -y
fi

echo "Installation complete."

### --- END download_emulos.sh --- ###


### --- BEGIN configure_wifi.sh --- ###
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

### --- END configure_wifi.sh --- ###
