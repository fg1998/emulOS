#!/bin/bash
set -x
sudo apt update -y

#git
#sudo apt install git -y
#git clone https://github.com/fg1998/emulOS.git
#sudo apt-get install curl -y


#install X
sudo apt install --no-install-recommends \
  xserver-xorg \
  xinit \
  openbox \
  matchbox-window-manager -y

#xterm
sudo apt install xterm -y

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
python3 -m pip install --break-system-packages --user gdown

#Amiberry
sudo apt install build-essential git cmake libsdl2-dev libsdl2-ttf-dev libsdl2-image-dev libflac-dev libmpg123-dev libpng-dev libmpeg2-4-dev libserialport-dev libportmidi-dev libenet-dev -y

#coco
sudo apt install libsdl2-dev automake libasound2-dev libsndfile1-dev texinfo zlib1g-dev libpulse-dev -y

#dosbox
sudo apt install libsdl-sound1.2 libsdl-net1.2

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

cd emulOS

npm install && npm start



