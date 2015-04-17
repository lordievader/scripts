#!/bin/bash
#NUMPACKAGES=$(echo $0|sed 's,.*top\([0-9]*\).*,\1,')
NUMPACKAGES=$2

function get {
  qsize -am | awk '{
    Package = substr($1, 1, length($1) - 1);
    Size = $6;
    printf "%u %s\n", Size, Package;
  }'|sort -nr
}

function output {
  awk '{
    Package = $2;
    Size = $1;
    printf "%s -- %u MiB\n", Package, Size;
  }'|less
}

function all {
  get | output
}

function top {
  get | head -n $NUMPACKAGES | output
}

function depends {
  IFS=$'\n'
  for PACKAGE in $(if [[ ! -z $NUMPACKAGES ]]; then get | head -n $NUMPACKAGES; else get; fi); do
    SIZE=$(echo $PACKAGE|cut -d" " -f1)
    PACKAGE=$(echo $PACKAGE|sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"|cut -d" " -f2)
    echo "($SIZE MiB) $PACKAGE reverse depends:"
    equery --quiet depends $PACKAGE|awk '{
      Package = $1;
      printf "\t%s\n", Package;
    }'
    echo ""
  done|less
}

if [[ "$1" == '--depends' ]]; then
  depends
elif [[ "$1" == "--top" ]]; then
  top
else
  all
fi
