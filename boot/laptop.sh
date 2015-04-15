#!/bin/bash
export DISPLAY=:0
## Mount Truecrypt drives
sudo truecrypt --mount /dev/sda5 /media/Documents
#sudo truecrypt --mount /dev/sda8 /media/Photos

## Load display config
xrandr --output LVDS --auto
/home/lordievader/scripts/gamma.sh LVDS --set
/home/lordievader/scripts/gamma.sh CRT1 --set
