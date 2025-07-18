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
  -y

  sudo apt-get install \
  libatk-bridge2.0-0 \
  libgtk-3-0 \
  libnss3 \
  libxss1 \
  libasound2 \
  libdrm2 \
  -y
  
  sudo apt-get install \
  libxrandr2 \
  libxcomposite1 \
  libxdamage1 \
  libxfixes3 \
  libxcb-dri3-0 \
  libgbm1 \
  -y
  
  sudo apt-get install \
  libxkbcommon0 \
  libxkbcommon-x11-0 \
  alsa-utils alsa-oss \
  systemd \
  systemd-sysv \
  libsdl2-2.0-0 \
  libportmidi0 \
  -y

  sudo apt-get install \
  libmpeg2-4 \
  libnet1 \
  libsdl1.2debian \
  libsdl-sound1.2 \
  libsdl-net1.2 \
  libavformat59 \
  libserialport0 \
  libenet7 \
  libsdl2-ttf-2.0-0 \
  libsdl2-image-2.0-0 \
  libswscale6 \
  libncurses6 \
  -y


  sudo apt-get install \
  libslirp0 \
  libfluidsynth3 \
  libsdl-image1.2 \
  libzip4 \
  libtcl8.6 \
  libglew2.2 \
  libatk-bridge2.0-0 \
  libgtk-3-0 \
  libpulse0 \
  -y

sudo apt-get install libsdl1.2debian \
  libsdl-image1.2 \
  libsdl2-image-2.0-0 \
  pulseaudio \
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
