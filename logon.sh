#!/bin/bash
export DISPLAY=:0

# Start kmc
cd /home/$USER
if ! pgrep python3; then
  echo "Starting KMCD"
  nohup python3 /home/lordievader/Projects/Python/kmc/main.py&
fi

# Load gamma settings
#/home/lordievader/scripts/gamma2.sh --icc
/home/lordievader/scripts/gamma2.sh --load
