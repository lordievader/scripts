#!/bin/bash

ls | while read -r FILE
do
    mv -v "$FILE" `echo $FILE | tr ' ' '_' | tr -d '[{}(),\!]' | tr -d "\'"  | sed 's/_-_/_/g'`
done
