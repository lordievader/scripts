#!/bin/bash
export DISPLAY=:0
export SSH_ASKPASS=/usr/bin/ksshaskpass
export XAUTHORITY=/tmp/xauth-1000-_0


# Define a mount dictionary
declare -A nfs=( ["/home/lordievader"]="/mnt/data/homedir"
                    ["/home/lordievader/Downloads"]="/mnt/data/downloads"
                    ["/mnt/multimedia/shows"]="/mnt/multimedia/shows"
                    ["/mnt/multimedia/movies"]="/mnt/multimedia/movies"
                    ["/mnt/multimedia/music"]="/mnt/multimedia/music"
                    ["/mnt/multimedia/photos"]="/mnt/multimedia/photos"
                    ["/mnt/data/software"]="/mnt/data/software"
                    ["/mnt/data/www"]="/mnt/data/www"
                    ["/mnt/data/src"]="/mnt/data/src"
                    ["/mnt/data/git"]="/mnt/data/git")


# Define the host
nfs_host='corellian-corvette.mini.true'
sshfs_host='corellian'

function findAgent () {
    AGENTPID=$(ps ux|grep '[s]sh-agent'|awk '{print $2}')
    SOCKPID=$(echo $AGENTPID -1|bc)
    SOCKPATH=$(/bin/ls /tmp/ssh-*/agent.$SOCKPID)
    export SSH_AUTH_SOCK=$SOCKPATH
}

function checkKey () {
  findAgent
  keyname=$1
  wanted_print=$(ssh-keygen -lf ~/.ssh/$keyname|cut -d' ' -f2)
  fingerprints=$(ssh-add -l|awk '{print $2}'|grep $wanted_print)
  if [ -z $fingerprints ]; then
    loaded=1
  else
    loaded=0
  fi
}

function loadSpecificKey () {
  findAgent
  keyname=$1
  echo "Loading key $key"
  TTY=$(tty)
  TTY=${TTY:0:8}
  if [ $TTY == '/dev/pts' ]; then
    ssh-add /home/lordievader/.ssh/$keyname < /dev/null
  else
    ssh-add /home/lordievader/.ssh/$keyname
  fi
  echo $?
  return $?
}

function loadAllKeys {
  findAgent
  keynames=('masterkey' 'millenium-falcon')
  for key in ${keynames[@]}; do
    checkKey $key
    if [ $loaded == 1 ]; then
      loadSpecificKey $key
    else
      echo "Key $key already loaded"
    fi
  done
}

function loadKey () {
  findAgent
  arg=$1
  if [[ $arg == *a* ]]; then
    loadAllKeys
  else
    checkKey $2
    if [ $loaded == 1 ]; then
      loadSpecificKey $2
    fi
  fi
}

function nfsMount () {
  host=$1
  target=$2
  destination=$3
  echo "$target --> $destination"
  if [ "$(mount|grep $destination\ )" == '' ]; then
    sudo mount -o rw,intr,nolock,tcp,rsize=32768,wsize=32768 $host:$target $destination
    if [ "$(mount|grep $destination)" == '' ]; then
      echo "Mount failed"
      return 1
    fi
  else
    echo "Already mounted"
  fi
  return 0
}

function sshfsMount () {
  findAgent
  host=$1
  target=$2
  destination=$3
  user='lordievader'
  #loadSpecificKey '/home/lordievader/.ssh/masterkey'
  #exit 1
  echo "$target --> $destination"
  if [ "$(mount|grep $destination\ )" == '' ]; then
    #sshfs -oauto_cache,reconnect,no_readahead -o allow_other,reconnect,idmap=user,ServerAliveInterval=5 $user@$host:$target $destination
    sshfs -o cache=yes,kernel_cache,compression=no,large_read,allow_other,reconnect,idmap=user,ServerAliveInterval=5 $user@$host:$target $destination
    if [ "$(mount|grep $destination)" == '' ]; then
      echo "Mount failed"
      return 1
    fi
  else
    echo "Already mounted"
  fi
  return 0
}

function truecryptMount () {
  target=$1
  destination=$2
  echo "$target --> $destination"
  if [ "$(mount|grep $destination)" == '' ]; then
    sudo truecrypt --mount $target $destination
    if [ "$(mount|grep $destination)" == '' ]; then
      echo "Mount failed"
      return 1
    fi
  else
    echo "Already mounted"
  fi
  return 0
}

function smbMount {
    echo Samba
    echo

    kdesudo ls

    unmount

    echo "Please enter your Samba password:"
    read -s password

    echo lordievader
    sudo mount -t cifs -o user=lordievader,password="$password",ip=127.0.0.1,port=1139,uid=lordievader,gid=lordievader,file_mode=0770,dir_mode=0770 //localhost/lordievader /media/lordievader

    echo Movies
    sudo mount -t cifs -o user=lordievader,password="$password",ip=127.0.0.1,port=1139,uid=lordievader,gid=lordievader,file_mode=0770,dir_mode=0770 //localhost/Movies /media/Movies

    echo Music
    sudo mount -t cifs -o user=lordievader,password="$password",ip=127.0.0.1,port=1139,uid=lordievader,gid=lordievader,file_mode=0770,dir_mode=0770 //localhost/Music /media/Music

    echo Storage
    sudo mount -t cifs -o user=lordievader,password="$password",ip=127.0.0.1,port=1139,uid=lordievader,gid=lordievader,file_mode=0770,dir_mode=0770 //localhost/Storage /media/Storage

    echo Web
    sudo mount -t cifs -o user=lordievader,password="$password",ip=127.0.0.1,port=1139,uid=lordievader,gid=lordievader,file_mode=0770,dir_mode=0770 //localhost/Web /media/Web

    echo Anime
    sudo mount -t cifs -o user=lordievader,password="$password",ip=127.0.0.1,port=1139,uid=lordievader,gid=lordievader,file_mode=0770,dir_mode=0770 //localhost/Anime /media/Anime
}

function kill_used () {
  mount=$1
  flags=$2
  used_by=($(lsof -t $mount))

  for pid in ${used_by[@]}; do
    echo "Filesystem used by $pid, killing. Flags: $flags"
    ps hp $pid
    kill $flags $pid
  done
}

function unmount_helper () {
  type=$1
  mount=$2
  lazy=$3

#   echo "Unmounting $mount"
  if [ $type == 'nfs' ]; then
    sudo umount $lazy $mount
  elif [ $type == 'sshfs' ]; then
    fusermount -u $lazy $mount
  elif [ $type == 'truecrypt' ]; then
    sudo truecrypt -d $mount
  fi
}

function unmount {

    # NFS mount points
    nfs_mounts=($(cat /proc/mounts|grep nfs|awk '{print $2}'))
    for mount in ${nfs_mounts[@]}; do
    counter=0
    echo "Unmounting $mount"
    while [ "$(cat /proc/mounts|grep nfs|awk '{print $2}'|grep $mount)" != '' ] && [ $counter -lt 5 ]; do
        if [[ $counter > 0 ]]; then
            echo "Try: $counter"
        fi
        if sudo fping -q -t100 -c1 8.8.8.8 &> /dev/null; then
            if [ $counter -lt 4 ]; then
                kill_used $mount
            else
                kill_used $mount '-9'
            fi
            unmount_helper 'nfs' $mount
        else
            unmount_helper 'nfs' $mount '-l'
        fi
        counter=$(echo $counter+1|bc)
    done
    if [ "$(cat /proc/mounts|grep nfs|awk '{print $2}'|grep $mount)" != '' ]; then
       echo "Unmount failed, will lazy unmount"
       unmount_helper 'nfs' $mount '-l'
    fi
  done

  # SSHFS mounts
  sshfs_mounts=($(cat /proc/mounts|grep sshfs|awk '{print $2}'))
  for mount in ${sshfs_mounts[@]}; do
    counter=0
    echo "Unmounting $mount"
    while [ "$(cat /proc/mounts|grep sshfs|awk '{print $2}'|grep $mount)" != '' ] && [ $counter -lt 5 ]; do
        if [[ $counter > 0 ]]; then
            echo "Try: $counter"
        fi
        if sudo fping -q -t100 -c1 8.8.8.8 &> /dev/null; then
#             if [ $counter -lt 4 ]; then
#                 kill_used $mount
#             else
#                 kill_used $mount '-9'
#             fi
            unmount_helper 'sshfs' $mount
        else
            unmount_helper 'sshfs' $mount '-z'
            unmount_helper 'nfs' $mount '-l'
        fi
        counter=$(echo $counter+1|bc)
    done
    if [ "$(cat /proc/mounts|grep sshfs|awk '{print $2}'|grep $mount)" != '' ]; then
        echo "Unmount failed, will lazy unmount"
        unmount_helper 'sshfs' $mount '-z'
        unmount_helper 'nfs' $mount '-l'
    fi
  done
}

##  Main loop
if [ -z $1 ]; then
  echo "Mount script
Usage: $0 [options]

  -m    mount directories
  -u    unmount directories"

elif [ $1 == "-m" ]; then

    # Check what transport protocol needs to be used and mount things
    if sudo fping -q -t100 -c1 8.8.8.8 &> /dev/null; then
        echo "Pinging"
        if sudo fping -q -t100 -c1 10.0.1.1 &> /dev/null; then
            echo "Using NFS"
            for mount in ${!nfs[@]}; do
                if ! nfsMount $nfs_host $mount ${nfs[$mount]}; then
                    exit 1
                fi
            done
        else
            echo "Using SSHFS"
            for mount in ${!nfs[@]}; do
            if ! sshfsMount $sshfs_host $mount ${nfs[$mount]}; then
                exit 1
            fi
            done
        fi
    else
        echo "No internet connection!"
    fi

elif [ $1 == "-u" ]; then
    unmount

elif [ $1 == "-c" ]; then
    if [ -z "$(mount|grep 'nfs\|sshfs')" ]; then
        echo "Not mounted"
        exit 1
    else
        echo "Mounted"
        exit 0
    fi

elif [[ $1 == -*k* ]]; then
    loadKey $1 $2
fi
