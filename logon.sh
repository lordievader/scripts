#!/bin/bash
export DISPLAY=:0

# Start synergy
#if [ $HOSTNAME == 'millenium-falcon' ]; then
#    if [ "$(pgrep synergys)" == '' ]; then
#        synergys -c ~/.synergy.conf
#    fi
#else
#    if [ "$(pgrep synergyc)" == '' ]; then
#        synergyc millenium-falcon
#    fi
#fi

# Start kmc
cd /home/$USER
if [ "$(pgrep kmcd.py)" == '' ]; then
  nohup /usr/share/kmc/kmcd.py&
fi

# Load gamma settings
/home/lordievader/scripts/gamma2.sh --load
