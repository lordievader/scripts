#!/bin/bash
if [ "$(whoami)" != 'root' ]; then
  echo "I need root rights"
  exit
fi
modprobe linear
losetup /dev/loop0 /home/lordievader/WindowsVM/boot.mbr
mdadm --build /dev/md0 --level=linear --raid-devices=3 /dev/loop0 /dev/sda1 /dev/sda2
