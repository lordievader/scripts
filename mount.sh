#!/bin/bash

# Define a mount dictionary
declare -A mounts=( ["/home/lordievader"]="/media/homedir"
                    ["/media/Anime"]="/media/Anime"
                    ["/media/Movies"]="/media/Movies"
                    ["/media/Music"]="/media/Music"
                    ["/media/Software"]="/media/Software"
                    ["/media/Storage"]="/media/Storage"
                    ["/www-int"]="/media/www-int"
                    ["/www-ext"]="/media/www-ext")
declare -A truecrypt=(["/dev/sda5"]="/media/Documents"
                      ["/dev/sda8"]="/media/Photos")

# Define the host
nfs_host='corellian-corvette.mini.true'
sshfs_host='lordievader.no-ip.org'

function loadKey {
    # We want to load the master key
    keyname='masterkey'
    wanted_print=$(ssh-keygen -lf ~/.ssh/$keyname|cut -d' ' -f2)
    fingerprints=($(ssh-add -l|awk '{print $2}'))
    loaded='false'
    for fingerprint in ${fingerprints[@]}
    do
      if [ $fingerprint == $wanted_print ]; then
        loaded='true'
      fi
    done
    if [ $loaded == 'false' ]; then
      echo "Loading key"
      ssh-add ~/.ssh/$keyname
    else
      echo "Key already loaded"
    fi
}

function nfsMount () {
  host=$1
  target=$2
  destination=$3
  echo "$target --> $destination"
  if [ "$(mount|grep $destination)" == '' ]; then
    sudo mount $host:$target $destination
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
  host=$1
  user='lordievader'
  target=$2
  destination=$3
  echo "$target --> $destination"
  if [ "$(mount|grep $destination)" == '' ]; then
    sshfs -o idmap=user,ServerAliveInterval=5 $user@$host:$target $destination
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
    ps hp $pid
    echo "Filesystem used by $pid, killing. Flags: $flags"
    kill $flags $pid
  done
}

function unmount_helper () {
  type=$1
  mount=$2
  lazy=$3

  echo "Unmounting $mount"
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
  nfs_mounts=($(df -hT|grep nfs|awk '{print $7}'))
  for mount in ${nfs_mounts[@]}; do
    counter=0
    echo $mount
    while [ "$(mount|grep $mount)" != '' ] && [ $counter -lt 5 ]; do
      echo "Try: $counter"
      if [ $counter -lt 4 ]; then
        kill_used $mount
      else
        kill_used $mount '-9'
      fi
      unmount_helper 'nfs' $mount
      counter=$(echo $counter+1|bc)
    done
    if [ "$(mount|grep $mount)" != '' ]; then
      echo "Unmount failed, will lazy unmount"
      unmount_helper 'nfs' $mount '-l'
    fi
  done

  # SSHFS mounts
  sshfs_mounts=($(df -hT|grep sshfs|awk '{print $7}'))
  for mount in ${sshfs_mounts[@]}; do
    counter=0
    echo $mount
    while [ "$(mount|grep $mount)" != '' ] && [ $counter -lt 5 ]; do
      echo "Try: $counter"
      if [ $counter -lt 4 ]; then
        kill_used $mount
      else
        kill_used $mount '-9'
      fi
      unmount_helper 'sshfs' $mount
      counter=$(echo $counter+1|bc)
    done
    if [ "$(mount|grep $mount)" != '' ]; then
      echo "Unmount failed, will lazy unmount"
      unmount_helper 'sshfs' $mount '-z'
    fi
  done

  # Truecrypt mounts
  truecrypt_mounts=($(df -hT|grep truecrypt|awk '{print $7}'))
  for mount in ${truecrypt_mounts[@]}; do
    counter=0
    echo $mount
    while [ "$(mount|grep $mount)" != '' ] && [ $counter -lt 5 ]; do
      echo "Try: $counter"
      if [ $counter -lt 4 ]; then
        kill_used $mount
      else
        kill_used $mount '-9'
      fi
      unmount_helper 'truecrypt' $mount
      counter=$(echo $counter+1|bc)
    done
    if [ "$(mount|grep $mount)" != '' ]; then
      echo "Unmount failed"
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
  if ping -q -c1 $nfs_host  > /dev/null; then
    echo "Using NFS"
    for mount in ${!mounts[@]}; do
      if ! nfsMount $nfs_host $mount ${mounts[$mount]}; then
        exit 1
      fi
    done
  else
    echo "Using SSHFS"
    for mount in ${!mounts[@]}; do
      if ! sshfsMount $sshfs_host $mount ${mounts[$mount]}; then
        exit 1
      fi
    done
  fi

elif [ $1 == "-t" ]; then
  
  # Truecrypt mounts
  echo "Mounting Truecrypt volumes"
  for mount in ${!truecrypt[@]}; do
    if ! truecryptMount $mount ${truecrypt[$mount]}; then
      exit 1
    fi
  done

elif [ $1 == "-u" ]; then
    unmount
elif [ $1 == "-k" ]; then
    loadKey
fi
