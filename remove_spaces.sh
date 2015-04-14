#!/bin/bash
for item in *; do mv $item "$(echo $item|sed 's,_,\ ,g')"; done
