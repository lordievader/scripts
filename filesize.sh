#!/bin/bash
DIR="$1"
if [[ $DIR != "" ]]; then
    DIR="$DIR/"
fi

#output=$(for item in * .* ; do
#    if [[ $item != '.' ]] && [[ $item != '..' ]]; then
#        du -xks $DIR"$item"
#    fi
#done | sort -nr | awk '{
#    Size = $1;
#    Directory = $2;
#    if ( Size > 1024 && Size <= 1048576 ) {
#        Size_MB = Size / 1024;
#        printf "%5u MB %-100s;", Size_MB, Directory;
#    }
#    else if ( Size > 1048576 ) {
#        Size_GB = Size / 1048576;
#        printf "%5u GB %-100s;\n", Size_GB, Directory;
#    }
#    else {
#        printf "%5u kB %-100s;\n", Size, Directory;
#    }
#
#  }')
#count=$(echo $output|sed 's,;,\n,g'|wc -l)
#if [[ $count -gt $(tput lines) ]]; then
#    echo $output|sed 's,;,\n,g'|less
#else
#    #echo $output|sed 's,;,\n,g'
#    echo $output
#fi


for item in * .* ; do
    if [[ $item != '.' ]] && [[ $item != '..' ]]; then
        du -xks $DIR"$item"
    fi
done | sort -nr | awk '{
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

  }'|less -c
