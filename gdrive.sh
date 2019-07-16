#!/bin/bash
# Sync Google Drive
cd ~/GoogleDrive/
/usr/bin/grive 2&> 1 > /dev/null

# Move things to the correct dir
/home/lordievader/scripts/gphoto.py > /dev/null

# Rsync stuff
rsync -av ~/GoogleDrive/Google\ Photos/ /mnt/multimedia/photos/Phone/ > /dev/null
rsync -av --include '*/' --include '*.DNG' --exclude '*' ~/GoogleDrive/dng/ /mnt/multimedia/photos/DNG-import/ > /dev/null


find ~/GoogleDrive/dng/ -type f -exec rm {} +

/usr/bin/grive 2&> 1 > /dev/null
