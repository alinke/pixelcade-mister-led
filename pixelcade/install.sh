#!/bin/bash
pixelcade_detected=false
java_installed=false
install_succesful=false
#INSTALLDIR=upgrade
INSTALLDIR=$(pwd)


cat << "EOF"
       _          _               _
 _ __ (_)_  _____| | ___ __ _  __| | ___
| '_ \| \ \/ / _ \ |/ __/ _` |/ _` |/ _ \
| |_) | |>  <  __/ | (_| (_| | (_| |  __/
| .__/|_/_/\_\___|_|\___\__,_|\__,_|\___|
|_|
EOF

echo "${magenta}       Pixelcade Launcher for ALU $version    ${white}"
echo ""
echo "Now connect Pixelcade to a USB hub connected to the ALU"
echo "Ensure the toggle switch on the Pixelcade board is pointing towards USB and not BT"
#let's check if pixelweb is already running and if so, kill it
if ps aux | grep -q 'pixelweb'; then
   echo "${yellow}Pixelcade Already Running${white}"
   ps -ef | grep pixelweb | grep -v grep | awk '{print $1}' | xargs kill
fi

echo "${yellow}SETTING UDEV RULES${white}"
cp /$INSTALLDIR/50-pixelcade.rules /etc/udev/rules.d
/etc/init.d/S10udev stop
/etc/init.d/S10udev start

# detect what OS we have
if ls /dev/pixelcade | grep -q '/dev/pixelcade'; then
   echo "${yellow}PIXELCADE DETECTED${white}"
else
    echo "${red}Sorry, Pixelcade LED Marquee was not detected, please ensure Pixelcade is USB connected to your Pi and the toggle switch on the Pixelcade board is pointing towards USB, exiting..."
   exit 1
fi

echo "Setting up Java..."
export JAVA_HOME=/$INSTALLDIR/jre11
export PATH=$JAVA_HOME/bin:$PATH
chmod +x /$INSTALLDIR/jre11/bin/java

if [[ -d "/$INSTALLDIR/jre11" ]]; then
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

#pixelcade won't connect the first time so this is a hack / work around
java -jar pixelweb.jar -b &
last_pid=$!
sleep 10
kill -KILL $last_pid
#now let's start it again
java -jar pixelweb.jar -b &

#cd /$INSTALLDIR/pixelcade
#java -jar pixelcade.jar -m stream -c alu -g btime

#echo " "
#while true; do
#    read -p "${magenta}Is the Burgertime Game Logo Displaying on Pixelcade Now? (y/n)${white}" yn
#    case $yn in
#        [Yy]* ) echo "${green}INSTALLATION COMPLETE${white}"; break;;
#        [Nn]* ) echo "${red}Please check that pixelweb is running in the background and you may need to kill the pid using ps aux | grep pixelweb and try again" && exit;;
#        * ) echo "Please answer yes or no.";;
#    esac
#done
