#!/bin/bash
# Prints some statistics about the backup.
function log () {
    printf "%s: %s\n" "$(date +"%Y-%m-%d %H:%M")" "${@}"
}
function checkLV {
    OLD_IFS=$IFS
    IFS=$'\n'

    available=1
    for item in $(lvs -o lv_name,lv_attr --noheadings|grep backup|sed -e 's,^\ \+,,g' -e 's,\ \+, ,g'); do
        if [[ "${item/[a-z-]* /}" != 'rwi-a-r---' ]]; then
            available=0
            log "${item/ [a-z-]*/} is not available"
        fi
    done
    IFS=$OLD_IFS
    return $available
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
    stats
    umountBackup
fi
