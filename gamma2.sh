#!/bin/bash
cd ~
export DISPLAY=:0

saveFile="Documents/local/files/gamma.txt"

function getmonitors {
  MONITORS=($(xrandr |grep " connected"|awk '{print $1}'))
}

function loadsettings () {
  MONITOR="$1"
  RED=$(cat $saveFile|grep "$MONITOR"r|sed 's/^.*=//g')
  GREEN=$(cat $saveFile|grep "$MONITOR"g|sed 's/^.*=//g')
  BLUE=$(cat $saveFile|grep "$MONITOR"b|sed 's/^.*=//g')
}

function setgamma () {
  MONITOR="$1"
  RED="$2"
  GREEN="$3"
  BLUE="$4"
  echo "Setting '$MONITOR' to $RED:$GREEN:$BLUE"
  xrandr --output $MONITOR --gamma $RED:$GREEN:$BLUE
}

function configureRed () {
  MONITOR="$1"
  RED="$2"
  GREEN="$3"
  BLUE="$4"
  DONE=0
  clear
  while [[ $DONE == 0 ]]; do
    echo "Red gamma value? (s to save)"
    read -e ANSWER
    if [[ $ANSWER == 's' ]]; then
      DONE=1
    else
      RED=$ANSWER
      setgamma $MONITOR $RED $GREEN $BLUE
    fi
  done
}

function configureGreen () {
  MONITOR="$1"
  RED="$2"
  GREEN="$3"
  BLUE="$4"
  DONE=0
  clear
  while [[ $DONE == 0 ]]; do
    echo "Green gamma value? (s to save)"
    read -e ANSWER
    if [[ $ANSWER == 's' ]]; then
      DONE=1
    else
      GREEN=$ANSWER
      setgamma $MONITOR $RED $GREEN $BLUE
    fi
  done
}

function configureBlue () {
  MONITOR="$1"
  RED="$2"
  GREEN="$3"
  BLUE="$4"
  DONE=0
  clear
  while [[ $DONE == 0 ]]; do
    echo "Blue gamma value? (s to save)"
    read -e ANSWER
    if [[ $ANSWER == 's' ]]; then
      DONE=1
    else
      BLUE=$ANSWER
      setgamma $MONITOR $RED $GREEN $BLUE
    fi
  done
}

function save () {
  MONITOR="$1"
  RED="$2"
  GREEN="$3"
  BLUE="$4"
  CONFIG=($(cat $saveFile))
  echo -n "" >$saveFile
  for LINE in ${CONFIG[@]}; do
    if [[ ! -z "$(echo $LINE|grep -v $MONITOR)" ]]; then
      echo $LINE >> $saveFile
    fi
  done
  echo "$MONITOR"r=$RED>>$saveFile
  echo "$MONITOR"g=$GREEN>>$saveFile
  echo "$MONITOR"b=$BLUE>>$saveFile
}

function configure () {
  MONITOR="$1"
  loadsettings $MONITOR
  if [[ ! -z $RED ]]; then
    clear
    echo "Current settings: R$RED, G$GREEN, B$BLUE"
    OLDRED=$RED
    OLDGREEN=$GREEN
    OLDBLUE=$BLUE
  else
    RED=1
    GREEN=1
    BLUE=1
  fi
  setgamma $MONITOR 1 1 1
  configureRed $MONITOR $RED $GREEN $BLUE
  configureGreen $MONITOR $RED $GREEN $BLUE
  configureBlue $MONITOR $RED $GREEN $BLUE
  if [[ ! -z $OLDRED ]]; then
    echo "Red: $OLDRED -> $RED"
    echo "Green: $OLDGREEN -> $GREEN"
    echo "Blue: $OLDBLUE -> $BLUE"
  fi
  echo "Would you like to save this configuration?"
  read -e ANSWER
  if [[ $ANSWER == "yes" ]]; then
    save $MONITOR $RED $GREEN $BLUE
  fi
}

function load () {
  MONITOR="$1"
  if [[ -z $MONITOR ]]; then
    for MONITOR in ${MONITORS[@]}; do
      loadsettings $MONITOR
      setgamma $MONITOR $RED $GREEN $BLUE
    done
  else
    loadsettings $MONITOR
    setgamma $MONITOR $RED $GREEN $BLUE
  fi
}

function reset () {
  MONITOR="$1"
  if [[ -z $MONITOR ]]; then
    for MONITOR in ${MONITORS[@]}; do
      setgamma $MONITOR 1 1 1
    done
  else
    setgamma $MONITOR 1 1 1
  fi
}

function main () {
  getmonitors
  if [[ -z "$1" ]]; then
    clear
    echo -n "What display to configure? ["
    for MONITOR in ${MONITORS[@]}; do
      echo -n " $MONITOR"
    done
    echo " ]"
    read -e MONITOR
    configure $MONITOR
  elif [[ "$1" == "--load" ]]; then
    load $2
  elif [[ "$1" == "--reset" ]]; then
    reset $2
  fi
}

main $1 $2
