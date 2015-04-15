#!/bin/bash
sleep 30

## Mount Truecrypt drives
sudo truecrypt --mount /dev/sda5 /media/Documents -p r1N0\!O_+P3LL3132
sudo truecrypt --mount /dev/sda9 /media/Photos -p r1N0\!O_+P3LL3132

## Desktop 1: Clementine
#xdotool keydown ctrl
#xdotool key F1
#xdotool keyup ctrl
#clementine&
#sleep 5

## Desktop 2: Chrome
#xdotool keydown ctrl
#xdotool key F2
#xdotool keyup ctrl
#chromium-browser&
#sleep 10

## Desktop 3: Thunderbird
#xdotool keydown ctrl
#xdotool key F3
#xdotool keyup ctrl
#thunderbird&
#sleep 10

## Desktop 5: Konsole
xdotool keydown ctrl
xdotool key F5
xdotool keyup ctrl
konsole&
sleep 5
#xdotool key F11
xdotool key ctrl+shift+m
sleep 5
xdodool type byobu
#xdotool type /home/lordievader/scripts/boot/console.sh
xdotool key KP_Enter
#sleep 5
