#!/bin/bash
BACKUP_MOUNTED=$(cryptsetup status /dev/mapper/backup|head -n1|awk '{print $3}')
if [ $BACKUP_MOUNTED == "active" ]; then
  echo "Mounting backup"
  mount /backup/corellian-corvette
  mount /backup/han-solo
  mount /backup/r2d2
  mount /backup/padme
  echo "Done"

  echo "Starting run"
  /usr/sbin/dirvish-runall
  echo "Done"
  
  echo "Stats"
  df -h|grep -e Filesystem -e backup

  echo "Unmounting backup"
  umount /backup/corellian-corvette
  umount /backup/han-solo
  umount /backup/r2d2
  umount /backup/padme
  echo "Done"
else
  echo "Backup not unlocked!"
fi
