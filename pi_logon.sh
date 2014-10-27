#!/bin/bash
DISPLAY=$(xrandr 2>/dev/null|grep Screen|awk '{print $2}'|sed 's/://g')
echo "Setting DISPLAY environment to :$DISPLAY"
export DISPLAY=:$DISPLAY
cd /home/$USER

scripts=('pulseaudio' 'synergys' '/usr/share/kmc/kmcd.py' 'xscreensaver')
declare -A arguments=(  ["pulseaudio"]="--start"
			["synergys"]="-c /home/$USER/.synergy.conf"
			["/usr/share/kmc/kmcd.py"]="nohup"
			["xscreensaver"]="")

function execute_command () {
	program=$1
	arguments=$2
	if [ "$arguments" == "nohup" ]; then
		command="nohup $program&"
	else
		command="$program $arguments&"
	fi
	echo $command
	eval $command
}

function wallpaper () {
	# Start the wallpaper manager
	echo "Starting Wallpaper manager"
	nohup /home/lordievader/scripts/wallpaper.py 1800 /mnt/data/www/kasui/images/1024&
}

function main () {

	for item in ${scripts[@]}; do
		if [ "$(pgrep `echo $item|sed 's,/.*/,,g'`)" == '' ]; then

			echo "Starting $item"
			execute_command $item "${arguments[$item]}"
		else
			echo "$item already started"
		fi
	done 
	wallpaper
}

main


