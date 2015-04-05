#!/bin/bash
export DISPLAY=:0

# Unmount filesystems
/home/lordievader/scripts/mount.sh -u

# Lock screen
qdbus org.freedesktop.ScreenSaver /ScreenSaver Lock

# Send computer to sleep
sleep 1
sudo pm-suspend

# Wait for the wake up
sleep 1

# Sort of fixes the FGLRX wake up bug
#xrandr --output LVDS --off
#xrandr --output LVDS --auto

# Reapply gamma, if needed
/home/lordievader/scripts/gamma2.sh --load

# Wait for the network to be up
counter=0
while ! ping -q -c1 8.8.8.8 && [ $counter -lt 5 ] ; do
  sleep 10
  counter=$(echo $counter+1|bc)
done

# If network is up, mount filesystems
if ping -q -c1 8.8.8.8; then
  /home/lordievader/scripts/mount.sh -m
fi

# Restart Pulseaudio
pulseaudio -k
pulseaudio --start
