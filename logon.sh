#!/bin/bash
export DISPLAY=:0

# Start synergy
if [ $HOSTNAME == 'soulless-one' ] && [ $HOSTNAME != 'star-destroyer' ]; then
    if [ "$(pgrep synergys)" == '' ]; then
        synergys -c ~/.synergy.conf
    fi
else
    if [ "$(pgrep synergyc)" == '' ]; then
        synergyc soulless-one
    fi
fi

# Start kmc
cd /home/$USER
if [ "$(pgrep recieve.py)" == '' ]; then
  nohup /usr/share/kmc/kmcd.py&
fi

# Load gamma settings
cd /home/$USER
screen=$(xrandr|grep "\ connected"|cut -d ' ' -f1)
./scripts/gamma.sh $screen --set

# Restart MPD/Pulseaudio
#if [ $HOSTNAME == 'star-destroyer' ]; then
#  ssh lordievader@corellian-corvette "sudo service music restart"
#fi
