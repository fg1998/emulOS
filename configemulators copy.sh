#!/bin/sh

set -x
sudo apt update -y

#git
#sudo apt install git -y
#git clone https://github.com/fg1998/emulOS.git
#sudo apt-get install curl -y

sudo apt install --no-install-recommends \
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
  -y


sudo apt install dialog -y
  #!/bin/sh

#!/bin/bash

cat > ~/.xinitrc << 'EOF'
#!/bin/sh

# Ajuste de DPI para o Pi400, melhora o xterm e fontes
xrdb -merge <<EOD
Xft.dpi: 96
XTerm*faceName: DejaVu Sans Mono
XTerm*faceSize: 12
EOD

# Abre o terminal e o gerenciador de janelas
xterm &
exec openbox
EOF

chmod +x ~/.xinitrc

sudo apt-get install curl -y


#NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
##MISSING EXPORT NVM COMMANDS
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
#NODE
nvm install --lts


## FUSE
#sudo apt install libsdl1.2-dev libpng-dev zlib1g-dev libbz2-dev libaudiofile-dev bison flex devscripts x11proto-core-dev libdirectfb-dev libraspberrypi-dev -y

#gdown
sudo apt install python3 python3-pip -yg
python3 -m pip install --break-system-packages --user gdown

# Garante que ~/.local/bin esteja no PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc
  export PATH=$PATH:$HOME/.local/bin
fi


#Amiberry
sudo apt install build-essential git cmake libsdl2-dev libsdl2-ttf-dev libsdl2-image-dev libflac-dev libmpg123-dev libpng-dev libmpeg2-4-dev libserialport-dev libportmidi-dev libenet-dev -y

#coco
sudo apt install libsdl2-dev automake libasound2-dev libsndfile1-dev texinfo zlib1g-dev libpulse-dev -y

#dosbox
sudo apt install libsdl-sound1.2 libsdl-net1.2 -y

#dosbox-x
sudo apt install libavformat59 libavcodec59 libavutil57 libswscale6 libslirp0 libfluidsynth3 -y


#linapple
sudo apt install libzip-dev libsdl1.2-dev libsdl-image1.2-dev libcurl4-openssl-dev libzip-dev libsdl1.2-dev libsdl-image1.2-dev libcurl4-openssl-dev zlib1g-dev imagemagick -y

#miniVmac
sudo apt install libsdl2-dev -y

#openMSX
sudo apt install libsdl2-dev libsdl2-ttf-dev libao-dev libogg-dev libtheora-dev libxml2-dev libvorbis-dev tcl-dev libasound2-dev libfreetype6-dev libglew-dev -y

#sdlTRS
sudo apt install libsdl2-dev libreadline-dev -y

#vice
sudo apt install libsdl2-dev libsdl2-image-dev libmpg123-dev libpng-dev zlib1g-dev libasound2-dev libvorbis-dev libflac-dev libpcap-dev automake bison flex libjpeg-dev portaudio19-dev xa65 dos2unix -y

#ZEsarUX
sudo apt-get install libssl-dev libpthread-stubs0-dev libasound2-dev libsdl2-dev -y


gdown -id 1Ooj-wX8HZBU3yDXbs338Wya9_fVqO_2w
#https://drive.google.com/file/d/1Ooj-wX8HZBU3yDXbs338Wya9_fVqO_2w/view?usp=share_link

sudo tar -xvzf /home/emulos/emulators.tar.gz -C / --strip-components=1


sudo apt install \
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
  libxkbcommon-x11-0 -y

  sudo apt install alsa-utils alsa-oss libasound2 -y

  sudo apt install systemd systemd-sysv pulseaudio -y
  systemctl --user start pulseaudio



cd emulOS

npm install && npm start



