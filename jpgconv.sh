#!/bin/bash
INPUTFILE="$1"
OUTPUTFILE=$(echo $INPUTFILE|sed 's,jpe,jpg,g')

if [[ "$INPUTFILE" != "$OUTPUTFILE" ]]; then
  mv $INPUTFILE $OUTPUTFILE
fi
