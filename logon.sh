#!/bin/bash
export DISPLAY=:0

# Start synergy
if [ $HOSTNAME == 'millenium-falcon' ]; then
    if [ "$(pgrep synergys)" == '' ]; then
        synergys -c ~/.synergy.conf
    fi
else
    if [ "$(pgrep synergyc)" == '' ]; then
        synergyc millenium-falcon
    fi
fi

# Start kmc
cd /home/$USER
if [ "$(pgrep kmcd.py)" == '' ]; then
  nohup /usr/share/kmc/kmcd.py&
fi

# Load gamma settings
cd /home/$USER
screens=($(xrandr|grep "\ connected"|cut -d ' ' -f1))
for screen in ${screens[@]}; do
  ./scripts/gamma.sh $screen --set
done

# Restart MPD/Pulseaudio
#if [ $HOSTNAME == 'star-destroyer' ]; then
#  ssh lordievader@corellian-corvette "sudo service music restart"
#fi
