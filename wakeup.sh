#!/bin/bash
export DISPLAY=:0
cd /home/lordievader/scripts
./gamma2.sh --load
./networkmanager.py

if ./first_wake.py; then
  echo "First Wake"
fi
sleep 5
./mount.sh -m
