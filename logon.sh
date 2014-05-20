#!/bin/bash
export DISPLAY=:0
if [ $HOSTNAME == 'star-destroyer' ]; then
    if [ "$(pgrep synergys)" == '' ]; then
        synergys -c ~/.synergy.conf
    fi
else
    if [ "$(pgrep synergyc)" == '' ]; then
        synergyc star-destroyer
    fi
fi
nohup /usr/share/kmc/recieve.py&
