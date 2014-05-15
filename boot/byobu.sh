#!/bin/bash
## Open Byobu
#xdotool type byobu
#xdotool key KP_Enter

## Make a new window
xdotool key F2

## Split and resize
xdotool key ctrl+a
xdotool key 0
xdotool key ctrl+a
xdotool key S
xdotool key ctrl+a
xdotool type ":resize 4"
xdotool key KP_Enter

## Run the console service
xdotool type /home/lordievader/scripts/boot/consoleservice.sh
xdotool key KP_Enter

## Change the main window to #1
xdotool key ctrl+a
xdotool key Tab
xdotool key ctrl+a
xdotool key 1
xdotool type "cd; clear"
xdotool key KP_Enter
