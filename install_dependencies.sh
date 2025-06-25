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
#sudo apt-get update -y

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
  systemd \
  systemd-sysv \
  pulseaudio \
  libsdl2-2.0-0 \
  libserialport \
  libportmidi0 \
  libmpeg2-4 \
  libnet1 \
  -y





# Ajusta o PATH caso ~/.local/bin não esteja
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc
  export PATH=$PATH:$HOME/.local/bin
fi


# Inicia o pulseaudio (precisa para alguns emuladores)
systemctl --user start pulseaudio

# Mensagem final de sucesso
dialog --title "Installation Complete" --msgbox "The EmulOS environment has been successfully installed!" 8 50

exit 0
