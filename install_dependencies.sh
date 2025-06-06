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
