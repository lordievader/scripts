#!/bin/bash
export DISPLAY=:0

# Get some displays
DISPLAYS=($(xrandr|grep "\ connected"|cut -d" " -f1))

# Get resolutions
for SCREEN in ${DISPLAYS[@]}; do
	RESOLUTION=$(xrandr|grep -A1 "$SCREEN\ "|tail -n1|awk '{print $1}')
	if [ $SCREEN == 'CRT1' ] && [ -z "$(xrandr|grep \"$SCREEN\ \"|grep '1280x1024')" ]; then
		RESOLUTION="1280x1024"
	fi
	xrandr --output $SCREEN --off
	xrandr --output $SCREEN --mode $RESOLUTION
done