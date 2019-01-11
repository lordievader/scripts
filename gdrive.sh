#!/bin/bash
# Sync Google Drive
cd ~/GoogleDrive/
/usr/bin/grive

# Move things to the correct dir 
/home/lordievader/scripts/gphoto.py

# Rsync stuff
rsync -av ~/GoogleDrive/Google\ Photos/ /mnt/multimedia/photos/Phone/
rsync -av --include '*/' --include '*.DNG' --exclude '*' ~/GoogleDrive/dng/ /mnt/multimedia/photos/DNG-import/

rm -r ~/GoogleDrive/dng/*
/usr/bin/grive
