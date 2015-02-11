#!/bin/bash
cd ~
clear
export DISPLAY=:0

if [ -z $1 ]; then
  xrandr |grep "connected"
  echo "What display to configure?"
  read -e CRT

else
  CRT="$1"
fi

LENGTH=$(echo ${#CRT} + 2 | bc)
r=$(cat Documents/local/files/gamma.txt|grep "$CRT"r)
r=${r:$LENGTH}
g=$(cat Documents/local/files/gamma.txt|grep "$CRT"g)
g=${g:$LENGTH}
b=$(cat Documents/local/files/gamma.txt|grep "$CRT"b)
b=${b:$LENGTH}

VALUE="$3"

if [ $2 == "--set" ]; then
  xrandr --output $CRT --gamma $r:$g:$b
  echo "Red: $r, green: $g, blue: $b"

elif [ $1 == "--help" ]; then
  echo -e "Options: \n ./gamma.sh CRT_monitor_# Channel(R/G/B) \n --set loads in default values"
  
else
  if [ $2 == "r" ]; then
    echo "What red gamma value? For "$CRT" Enter 's' to save the previous value."
    read -e GAMMA
    if [ $GAMMA == "s" ]; then
      cat Documents/local/files/gamma.txt | grep -v "$CRT""r" > Documents/local/files/gamma2.txt
      echo "$CRT""r=$VALUE" >> Documents/local/files/gamma2.txt
      cat Documents/local/files/gamma2.txt > Documents/local/files/gamma.txt
      ./scripts/gamma.sh $CRT g
    else
      xrandr --output $CRT --gamma $GAMMA:$g:$b
      ./scripts/gamma.sh $CRT r $GAMMA
    fi

  elif [ $2 == "g" ]; then
    echo "What green gamma value? For "$CRT" Enter 's' to save the previous value."
    read -e GAMMA
    if [ $GAMMA == "s" ]; then
      cat Documents/local/files/gamma.txt | grep -v "$CRT""g" > Documents/local/files/gamma2.txt
      echo "$CRT""g=$VALUE" >> Documents/local/files/gamma2.txt
      cat Documents/local/files/gamma2.txt > Documents/local/files/gamma.txt
      ./scripts/gamma.sh $CRT b
    else
      xrandr --output $CRT --gamma $r:$GAMMA:$b
      ./scripts/gamma.sh $CRT g $GAMMA
    fi

  elif [ $2 == "b" ]; then
    echo "What blue gamma value? For "$CRT" Enter 's' to save the previous value."
    read -e GAMMA
    if [ $GAMMA == "s" ]; then
      cat Documents/local/files/gamma.txt | grep -v "$CRT""b" > Documents/local/files/gamma2.txt
      echo "$CRT""b=$VALUE" >> Documents/local/files/gamma2.txt
      cat Documents/local/files/gamma2.txt > Documents/local/files/gamma.txt

      echo "Configure another display? (y/n)"
      read -e CONFIGURE
      if [ $CONFIGURE == "y" ]; then
	./scripts/gamma.sh
      elif [ $CONFIGURE == "n" ]; then
	killall gamma.sh
      fi
      
    else
      xrandr --output $CRT --gamma $r:$g:$GAMMA
      ./scripts/gamma.sh $CRT b $GAMMA
    fi
  fi
  clear
  if [ -z $VALUE ]; then
    xrandr --output $CRT --preferred
  fi
  
  echo "What white gamma value? For "$CRT" Enter 's' to save the previous value."
  read -e GAMMA
  if [ $GAMMA == "s" ]; then
    cat Documents/local/files/gamma.txt | grep -v "$CRT"> Documents/local/files/gamma2.txt
    echo "$CRT""r=$VALUE" >> Documents/local/files/gamma2.txt
    echo "$CRT""g=$VALUE" >> Documents/local/files/gamma2.txt
    echo "$CRT""b=$VALUE" >> Documents/local/files/gamma2.txt
    cat Documents/local/files/gamma2.txt > Documents/local/files/gamma.txt
    ./scripts/gamma.sh $CRT r
  else
    xrandr --output $CRT --gamma $GAMMA:$GAMMA:$GAMMA
    ./scripts/gamma.sh $CRT a $GAMMA
  fi
fi
