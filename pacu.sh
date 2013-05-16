#! /bin/bash
#################################################################
#   PACU 0.1
#       PACS Automated Computer Utilities
#    _____          _       _____   ______
#   |_   _|        / \     |_   _|.' ____ \
#     | |         / _ \      | |  | (___ \_|
#     | |   _    / ___ \     | |   _.____`.
#    _| |__/ | _/ /   \ \_  _| |_ | \____) |
#   |________||____| |____||_____| \______.'
#           Copyright (c) 2013
#   <mribeirodantas at lais.huol.ufrn.br>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# Read further in the LICENSE file.
#
#################################################################

# Variables
PkgName=PACU_a0.1_noarch
PkgVersion=v0.1
if [ "$USER" == "" ];
then
  SUDO_USER="`who -m | awk '{print $1;}'`"
fi


# Functions
function send() {
  echo "send images"
}

function query() {
  echo query images
}
function plot() {
  echo plot dicom images
}
function dump() {
  echo dump PACS db
}
function restore() {
  echo restore PACS db
}
function miss() {
  echo "PACS Automated Computer Utilities" $PkgVersion
  echo "pacu [parameter] [option] [argument]"
  echo "Run the help for further information."
  echo "pacu --help"
}

function backup() {
# Preparing temporary files for parsing
if [ -d /tmp/pacu ];
then
  echo `grep "backup_source" /home/$USER/.pacu` > /tmp/pacu/backupLine
else
  mkdir /tmp/pacu && echo `grep "backup_source" /home/$USER/.pacu` > /tmp/pacu/backupLine
fi

# Number of folders to back up

echo `cat /tmp/pacu/backupLine | cut -d "\"" -f2` > /tmp/pacu/backupLine
n=`cat /tmp/pacu/backupLine | awk '-F[ ]' '{ t += NF - 1 } END { print t }'`
for i in `seq 0 $n`
do
  dir=`cat /tmp/pacu/backupLine  | cut -d " " -f$((i+1))`
  if [ "$dir" != "" ];
  then
    file=`echo $dir | gawk -F " " '{ print $1 }'`
    echo "Backing up $file.."
    sleep 1
    if [ -d "$file" ];
    then
      if [ "$1" == "full" ];
      then
        tar zcvf $1-$(basename $file)-`date +%Y%m%d`.tar.gz $file
        else if [ "$1" == "inc" ];
        then
          find $file -mtime -$2 -type f -print | tar zcvf $1-$(basename $file)-`date +%Y%m%d`.tar.gz -T -
        fi
      fi
    else
      echo "$file does not exist."
    fi
  fi
done
tar zcf backup-$1-`date +%Y%m%d`.tar.gz --remove-files $1*-`date +%Y%m%d`.tar.gz && echo "The backup process is finished." && exit 0
echo "There was an error and the backup process could not finish properly."
}

function help() {
  echo "PACS Automated Computer Utilities" $PkgVersion
  echo "pacu [parameter] [option] [argument]"
  echo -e "\nParameters\n"
  echo "  -s --send Send images to a PACS Server"
  echo "  -q --query  Query images from a PACS Server"
  echo "  -d --dump Dump the PACS Server database"
  echo "  -r --restore  Restore the PACS Server database"
  echo "  --full-backup Full backup of dcm4chee server"
  echo "  --inc-backup [days] Incremental backup"
  echo "  --freedups [options]"
  echo "  -h --help Display this help"
  echo -e "\nOptions\n"
}

function freedups() {
  /usr/local/bin/freedups
}

# Beginning
case "$1" in
  -s|--send)
    send
    ;;
  -q|--query)
    query
    ;;
  -p|--plot)
    plot
    ;;
  -d|--dump)
    dump
    ;;
  -r|--restore)
    restore
    ;;
  -h|--help)
    help
    ;;
  --full-backup)
    backup full
    ;;
  --inc-backup)
    if [ "$2" == "" ];
    then
      echo "You must inform the number of days after --inc-backup."
      exit 0
    else
      backup inc $2
    fi
    ;;
  --freedups)
    freedups
    ;;
  *)
    miss
    ;;
esac
