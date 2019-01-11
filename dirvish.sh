#!/bin/bash
function log () {
    printf "%s: %s\n" "$(date +"%Y-%m-%d %H:%M")" "${@}"
}

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
    log 'mounting backup'
    mount -v /backup
    log 'backup mounted'
}

function umountBackup {
    log 'unmounting backup'
    umount -v /backup
    if [[ $? != 0 ]]; then
        lsof /backup
    fi
    log 'backup unmounted'
}

function dirvishExpire {
    log 'expire current snapshots'
    dirvish-expire
    log 'done expire'
}

function dirvishRun {
    log 'starting Dirvish run'
    dirvish-runall
    log 'Dirvish is done'
}

function stats {
    log 'backup statistics'
    /backup/stats.sh $(date +"%Y%m%d")
    echo ''
    df -h /backup

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

