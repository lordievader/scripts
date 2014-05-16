#!/bin/bash
export DISPLAY=:0
nfs -u
sudo truecrypt -d /media/Documents
#sudo truecrypt -d /media/Photos

qdbus org.freedesktop.ScreenSaver /ScreenSaver Lock
sleep 1
sudo pm-suspend
sleep 1
xrandr --output LVDS --auto
sudo truecrypt --mount /dev/sda5 /media/Documents
#sudo truecrypt --mount /dev/sda8 /media/Photos
/home/lordievader/scripts/gamma.sh LVDS --set
#if [ "$(ping -q -c1 10.0.0.2)" ];then nfs -m ;fi
