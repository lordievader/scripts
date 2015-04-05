#!/bin/bash
export DISPLAY=:0
/home/lordievader/scripts/mount.sh -u

qdbus org.freedesktop.ScreenSaver /ScreenSaver Lock
sleep 1
sudo pm-suspend
sleep 1
#xrandr --output LVDS --off
#xrandr --output LVDS --auto
/home/lordievader/scripts/gamma2.sh --load

counter=0
while ! ping -q -c1 8.8.8.8 && [ $counter -lt 5 ] ; do
  sleep 1
  counter=$(echo $counter+1|bc)
done
if ping -q -c1 8.8.8.8; then
  /home/lordievader/scripts/mount.sh -m
fi
