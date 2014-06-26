#!/bin/bash
export DISPLAY=:0
/home/lordievader/scripts/mount.sh -u
#sudo truecrypt -d /media/Documents
#sudo truecrypt -d /media/Photos

qdbus org.freedesktop.ScreenSaver /ScreenSaver Lock
sleep 1
sudo pm-suspend
sleep 1
xrandr --output LVDS --auto
/home/lordievader/scripts/gamma.sh LVDS --set
/home/lordievader/scripts/mount.sh -t

counter=0
while ! ping -q -c1 8.8.8.8 && [ $counter -lt 5 ] ; do
  sleep 1
  counter=$(echo $counter+1|bc)
done
if ping -q -c1 8.8.8.8; then
  /home/lordievader/scripts/mount.sh -m
fi
