#!/bin/bash
# Mode '2560x1440_41' 162.00 2560 2608 2640 2720 1440 1443 1448 1468 +hsync +vsync
export DISPLAY=:0
xrandr --newmode '2560x1440_41' 162.00 2560 2608 2640 2720 1440 1443 1448 1468 +hsync +vsync
xrandr --addmode HDMI-1-2 '2560x1440_41'
if [[ "$(xrandr --current|grep HDMI-1-2|cut -d ' ' -f 2)" == "connected" ]]; then
    xrandr --output HDMI-1-2 --mode '2560x1440_41'
fi
