#!/bin/bash
function checkLV {
  available=true
  for item in $(lvs -o lv_name,lv_attr --noheadings|grep backup|sed -e 's,^\ \+,,g' -e 's,\ \+,+,g'); do
    name=$(echo $item|sed 's,+.*$,,')
    state=$(echo $item|sed 's,^.*+,,')
    if [[ "$state" != 'rwi-a-r--' ]]; then
      available=false
      echo "$name is not available"
    fi
  done
  return available
}

function mountBackup {
  echo -n "Mounting backup... "
  mount /backup/corellian-corvette
  mount /backup/vm
  echo "done!"
}

function umountBackup {
  echo -n "Unmounting backup... "
  umount /backup/corellian-corvette
  if [[ $? != 0 ]]; then
    echo
    lsof /backup/corellian-corvette
  fi
  umount /backup/vm
  if [[ $? != 0 ]]; then
    echo
    lsof /backup/vm
  fi
  echo "done!"
}

function dirvishExpire {
  echo "Running expire"
  dirvish-expire
  echo "Done"
}

function dirvishRun {
  echo "Starting dirvish run"
  dirvish-runall
  echo "Done"
}

function stats {
    echo "Stats"
    df -h|grep -e Filesystem -e backup
    echo "Done"
}

if [[ checkLV == false ]]; then
  echo "One or more LogicalVolumes are not available."
  exit 1
else
  mountBackup
  dirvishExpire
  dirvishRun
  stats
  sleep 60
  umountBackup
fi

exit 0
BACKUP_MOUNTED=$(cryptsetup status /dev/mapper/backup|head -n1|awk '{print $3}')
if [ $BACKUP_MOUNTED == "active" ]; then
  echo "Mounting backup"
  mount /backup/corellian-corvette
  mount /backup/vm
  #mount /backup/han-solo
  #mount /backup/r2d2
  #mount /backup/padme
  echo "Done"

  echo "Starting run"
  /usr/sbin/dirvish-runall
  echo "Done"
  
  echo "Stats"
  echo $(df -h|grep -e Filesystem -e backup)

  echo "Unmounting backup"
  umount /backup/corellian-corvette
  umount /backup/vm
  #umount /backup/han-solo
  #umount /backup/r2d2
  #umount /backup/padme
  echo "Done"
else
  echo "Backup not unlocked!"
fi
