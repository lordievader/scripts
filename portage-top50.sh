#!/bin/bash
NUMPACKAGES=$(echo $0|sed 's,.*top\([0-9]*\).*,\1,')

function top {
  qsize -am | awk '{
    Package = substr($1, 1, length($1) - 1);
    Size = $6;
    printf "%u %s\n", Size, Package;
  }'|sort -nr|head -n $NUMPACKAGES|awk '{
    Package = $2;
    Size = $1;
    printf "%s -- %u MiB\n", Package, Size;
  }'|less
}

function depends {
  IFS=$'\n'
  PACKAGES=($(qsize -am | awk '{
  Package = substr($1, 1, length($1) - 1);
  Size = $6;
  printf "%u %s\n", Size, Package;
  }'|sort -nr|head -n $NUMPACKAGES|sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"))

  for PACKAGE in ${PACKAGES[@]}; do
    SIZE=$(echo $PACKAGE|cut -d" " -f1)
    PACKAGE=$(echo $PACKAGE|cut -d" " -f2)
    echo "($SIZE) $PACKAGE reverse depends:"
    equery --quiet depends $PACKAGE|awk '{
      Package = $1;
      printf "\t%s\n", Package;
    }'
    echo ""
  done|less
}

if [[ "$1" == '--depends' ]]; then
  depends
else
  top
fi
