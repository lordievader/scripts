#!/bin/bash

function rootCheck
{
  if [ "$(whoami)" != 'root' ]; then
    echo "Please run this script as root"
    exit
  fi
}

function hostCheck()
{
  ping -q -c 1 -W 1 corellian-corvette.mini.true > /dev/null
  return $?
}

function mountCheck()
{
  if [ $1 == 'remote' ]; then REMOTE=1; else REMOTE=0; fi
  BACKUP_DIR="/backup/$2"
  if [ $REMOTE == 1 ]; then
    if [ -z "$(ssh root@corellian mount|grep $BACKUP_DIR)" ]; then
      echo "Backup partition '$BACKUP_DIR' not mounted"
      return 1
    fi
  else
    if [ -z "$(mount|grep $BACKUP_DIR)" ]; then
      return 1
    fi
  fi
  return 0
}

function mountPartition()
{
  BACKUP_DIR="/backup/$1"
  echo "Mounting remote"
  if ! $(ssh root@corellian mount $BACKUP_DIR); then
    return 1
  fi
  if ! mountCheck 'remote' $1; then
    return 1
  fi
  return 0
}

function unmountPartition()
{
  # FIXME: nfs takes the mount hostage
  return 0

  BACKUP_DIR="/backup/$1"
  echo "Unmounting remote"
  if ! $(ssh root@corellian umount $BACKUP_DIR); then
    return 1
  fi
  if mountCheck 'remote' $1; then
    return 1
  fi
  return 0
}

function mountNFS()
{
  SOURCE="corellian-corvette.mini.true:/backup/$1"
  DESTINATION="/backup/$1"
  echo "Mounting local ('$SOURCE' -> '$DESTINATION')"
  if ! $(mount $SOURCE $DESTINATION); then
    return 1
  fi
  if ! mountCheck 'local' $1; then
    return 1
  fi
  return 0
}

function unmountNFS()
{
  DESTINATION="/backup/$1"
  echo "Unmounting local"
  if ! $(umount $DESTINATION); then
    return 1
  fi
  if mountCheck 'local' $1; then
    return 1
  fi
  return 0
}

function exitBackup
{
  if mountCheck 'local' $HOSTNAME; then
    if ! unmountNFS $HOSTNAME; then
      echo "Unmounting local failed! Bailing"
      exit
    fi
  fi
  if mountCheck 'remote' $HOSTNAME; then
    if ! unmountPartition $HOSTNAME; then
      echo "Unmounting remote failed! Bailing"
    fi
  fi
  exit
}

function main()
{
  rootCheck
  if ! hostCheck; then
    echo "Corellian-Corvette not available"
    exit
  fi

  if ! mountCheck 'remote' $HOSTNAME; then
    if ! mountPartition $HOSTNAME; then
      echo "Mounting remote failed!"
      exitBackup
    fi
  fi

  echo "Backup partition '$HOSTNAME' mounted"
  if ! mountCheck 'local' $HOSTNAME; then
    if ! mountNFS $HOSTNAME; then
      echo "Mounting local failed!"
      exitBackup
    fi
  fi
  #exitBackup
}

main
