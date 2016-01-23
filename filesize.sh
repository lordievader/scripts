#!/bin/bash
DIR="$1"
if [[ $DIR != "" ]]; then
    DIR="$DIR/"
fi

for item in * .* ; do
    if [[ $item != '.' ]] && [[ $item != '..' ]]; then
        du -xks $DIR"$item"
    fi
done | sort -nr | sed -e 's|\([0-9]\+\)\s*\(.*\)|\1;\2|g' -e 's|\s\+|\*|g' -e 's|;|\ |g'| awk '{
    Size = $1;
    Directory = $2;
    if ( Size > 1024 && Size <= 1048576 ) {
        Size_MB = Size / 1024;
        printf "%5u MB %-50s\n", Size_MB, Directory;
    }
    else if ( Size > 1048576 ) {
        Size_GB = Size / 1048576;
        printf "%5u GB %-50s\n", Size_GB, Directory;
    }
    else {
        printf "%5u kB %-50s\n", Size, Directory;
    }

  }'|sed 's|\*|\ |g'|less -c
