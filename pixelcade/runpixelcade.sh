#!/bin/bash
pixelcade_detected=false
java_installed=false
INSTALLDIR=$(pwd)

cat << "EOF"
       _          _               _
 _ __ (_)_  _____| | ___ __ _  __| | ___
| '_ \| \ \/ / _ \ |/ __/ _` |/ _` |/ _ \
| |_) | |>  <  __/ | (_| (_| | (_| |  __/
| .__/|_/_/\_\___|_|\___\__,_|\__,_|\___|
|_|
EOF

echo "${magenta}       Pixelcade Launcher for MiSTer $version    ${white}"
echo ""
echo "Now connect Pixelcade to a USB hub connected to your MiSTer"
echo "Ensure the toggle switch on the Pixelcade board is pointing towards USB and not BT"
#let's check if pixelweb is already running and if so, kill it
if ps aux | grep -q 'pixelweb'; then
   echo "${yellow}Pixelcade Already Running${white}"
   ps -ef | grep pixelweb | grep -v grep | awk '{print $1}' | xargs kill
fi
# detect what OS we have
if ls /dev/ttyACM0 | grep -q '/dev/ttyACM0'; then
   echo "${yellow}PIXELCADE LED DETECTED${white}"
else
  echo "${red}Sorry, Pixelcade LED Marquee was not detected, please ensure Pixelcade is USB connected to your Pi and the toggle switch on the Pixelcade board is pointing towards USB, exiting..."
  #TO DO send message to ALU UI here that Pixelcade was not detected
  exit 1
fi

echo "Setting up Java..."
export JAVA_HOME=/$INSTALLDIR/pixeljre
export PATH=$JAVA_HOME/bin:$PATH
chmod +x /$INSTALLDIR/pixeljre/bin/java

if [[ -d "/$INSTALLDIR/pixeljre" ]]; then
  echo "Java is installed..."
else
  echo "${yellow}Java is not installed..."
  exit 1
fi

if type -p java ; then
  echo "${yellow}Java already installed, skipping..."
  java_installed=true
elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
  echo "${yellow}Java already installed, skipping..."
  java_installed=true
else
   echo "${yellow}Java not found, exiting...${white}"
   exit 1
fi

cd /$INSTALLDIR
# Start Pixelcade Listener
java -jar pixelweb.jar -b &
#echo "launching MiSTer front end integration"
./MiSTerCade -s
