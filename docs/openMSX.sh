
#!/bin/bash
#Running openMSX full screen
#$1 is machine name (whitout the xml)
#OPENMSX_USER_DATA=~/emulators/openmsx-bin/share
#export OPENMSX_USER_DATA

#~/emulators/openmsx-bin/bin/openmsx -command "set fullscreen on" -machine $1



git clone https://github.com/openMSX/openMSX.git
sudo apt install libsdl2-dev libsdl2-ttf-dev libao-dev libogg-dev libtheora-dev libxml2-dev libvorbis-dev tcl-dev libasound2-dev libfreetype6-dev libglew-dev -y

./configure
make clean
make

