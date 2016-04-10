#!/bin/bash
export DISPLAY=:0

# Start kmc
cd /home/$USER
if ! pgrep kmcd; then
  echo "Starting KMCD"
  nohup python3 /usr/share/kmc/main.py -d&
fi

# Load gamma settings
#/home/lordievader/scripts/gamma2.sh --icc
/home/lordievader/scripts/gamma2.sh --load
