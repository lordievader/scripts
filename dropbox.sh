#!/bin/bash
files=$(ls /home/lordievader/Dropbox/Camera\ Uploads)

if [ -z $files ]; then
  cat /dev/null
else
  mv "/home/lordievader/Dropbox/Camera Uploads"/* /media/Storage/.System32/Dropbox
fi
