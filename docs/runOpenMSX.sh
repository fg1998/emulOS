#!/bin/bash
#Running openMSX full screen
#$1 is machine name (whitout the xml)
OPENMSX_USER_DATA=~/emulators/openmsx-bin/share
export OPENMSX_USER_DATA

~/emulators/openmsx-bin/bin/openmsx -command "set fullscreen on" -machine $1