#!/bin/bash
if [ "$(whoami)" != 'root' ]; then
  echo "I need root rights"
  exit
fi
MOUNTED=0
if ! [ -z "$(mount|grep /mnt/windows)" ]; then
  umount /mnt/windows
  MOUNTED=1
  sleep 2
fi
modprobe linear
losetup /dev/loop0 /home/lordievader/WindowsVM/boot.mbr
mdadm --build /dev/md0 --level=linear --raid-devices=3 /dev/loop0 /dev/sda1 /dev/sda2

if [[ $MOUNTED == 1 ]]; then
  sleep 2
  mount /mnt/windows
fi
