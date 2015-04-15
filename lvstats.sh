#!/bin/bash
#lvs --noheadings --units g /dev/$VG-vg|sed -e 's/^\ \ //g' -e 's/g\ *$//g'|sort -nrk 4
IFS=$'\n'
function getVgs {
  volumeGroups=($(vgs --noheadings|sed 's,^\ *,,g'))
}

function isE2 () {
  disk=$(file -Ls $1|grep 'ext[0-9]'|sed 's,.*\(ext[0-9]\).*,\1,g')
  e2='true'
  if [[ -z $disk ]]; then
    e2='false'
  fi
}

function lvStat () {
  volumeGroup=$1
  vg=$(echo $volumeGroup|awk '{print $1}')
  for line in `lvs --noheadings --units b|awk '{Size = substr($4, 1, length($4) - 1); printf "%s %s %s %s\n", $1, $2,  $3,  Size}'`; do
    lv=$(echo $line|awk '{print $1}')
    lvPath="/dev/$vg/$lv"
    isE2 $lvPath
    if [[ $e2 == 'true' ]]; then
      fsStat=$(dumpe2fs -h $lvPath 2>&1|grep -v 'dumpe2fs'|grep 'Filesystem state\|Block count\|Reserved block count\|Free blocks\|Block size'|sed -e 's,\ \+,\ ,g' -e 's,^.*:\ ,,g'|xargs)
      echo "$line $fsStat"
    fi
  done|awk '{
    logicalVolume = $1;
    volumeGroup = $2;
    attributes = $3;
    size = int($4);
    state = $5;
    blockCount = int($6);
    reservedBlocks = int($7);
    freeBlocks = int($8);
    blockSize = int($9);

    freeSpace = (freeBlocks - reservedBlocks) * blockSize;
    fileSystem = (blockCount - reservedBlocks) * blockSize;

    freeSpaceGB = freeSpace / (1024^3);
    fileSystemGB = fileSystem / (1024^3);

    sizeGB = size / (1024^3);

    freeSpacePercent = (freeSpace / fileSystem) * 100;
    fileSystemPercent = (fileSystem / size) * 100;
    printf "%-30s %-20s %-5s %-5s %5ug %5ug %3u%% \n", logicalVolume, volumeGroup, state, attributes, sizeGB, freeSpaceGB, freeSpacePercent;
  }'|sort -nk 7|awk 'BEGIN {printf "%-30s %-20s %6s %-5s %10s %6s %4s\n", "LV", "VG", "State", "Attr", "Size", "Free", "%"}; {print}'
}

getVgs
for volumeGroup in ${volumeGroups[@]}; do
 lvStat $volumeGroup
done
