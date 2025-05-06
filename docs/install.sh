#!/bin/bash
sudo apt update

#install X
sudo apt install --no-install-recommends \
  xserver-xorg \
  xinit \
  openbox \
  matchbox-window-manager -y

sudo apt install xterm -y


sudo apt-get install git -y
git clone https://github.com/fg1998/emulOS.git
sudo apt-get install curl -y

#NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
** MISSING EXPORT NVM COMMANDS

nvm install --lts




cd emulOS



echo "Install fuse"
wget https://files.retropie.org.uk/archives/fuse-1.5.7.tar.gz
mkdir fuse
tar -xvf ./fuse-1.5.7.tar.gz -C ./fuse --strip-components 1
rm fuse-1.5.7.tar.gz

wget https://files.retropie.org.uk/archives/libspectrum-1.4.4.tar.gz
mkdir fuse/libspectrum
tar -xvf ./libspectrum-1.4.4.tar.gz -C ./fuse/libspectrum --strip-components 1
rm ./libspectrum-1.4.4.tar.gz

cd fuse/libspectrum
./configure --disable-shared
make clean
make

cd ..
mkdir bin
./configure --prefix="/home/fg1998/Downloads/fuse/bin" --without-libao --without-gpm --without-gtk --without-libxml2 --with-sdl LIBSPECTRUM_CFLAGS="-Ilibspectrum" LIBSPECTRUM_LIBS="-Llibspectrum/.libs -lspectrum"
make clean
make

//dependencias
libsdl1.2-dev libpng-dev zlib1g-dev libbz2-dev libaudiofile-dev bison flex
devscripts x11proto-core-dev libdirectfb-dev libraspberrypi-dev

descompactar o fuse em uma pasta
descompactar o libspetrum em uma pasta DENTRO da pasta do fuse

dentro da pasta libspectrum
 ./configure --disable-shared
    make clean
    make


dentro da pasta do fuse
./configure --prefix="fuse" --without-libao --without-gpm --without-gtk --without-libxml2 --with-sdl LIBSPECTRUM_CFLAGS="-Ilibspectrum-1.4.4" LIBSPECTRUM_LIBS="-Llibspectrum-1.4.4/.libs -lspectrum"

make



