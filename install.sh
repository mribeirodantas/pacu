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

# Workaround so that `su -c` works as much as `sudo`
if [ "$SUDO_USER" == "" ];
then
  SUDO_USER="`who -m | awk '{print $1;}'`"
fi

# Variables
version="a0.1"
arch="noarch"
pacudir="/home/$SUDO_USER/.pacu"
logpath="$pacudir/pacuLog"
bin="/usr/local/bin"

# Functions
function log()
{
  if ! printf '%s\n' "[  `date --date=now +%r`  ] $1" >&3
  then
    printf '%s\n' 'evil error cant write to logfile' >&2
    exit 1
  fi
  if [ "$2" == "print" ];
  then
    echo -e "$1"
  fi
}

function install()
{
  clear
  echo "pacu.$version-$arch"
  echo "Thank you for using the PACS Automated Computer Utilities!"
  echo "You may want to take a look at the RELEASE file in order"
  echo "to see what has changed since the last version!"
  echo -e "\nWe suggest you to read the README file, before"
  echo "going on. Do you want to continue?"
  read -n1 -p [Y/n] answer
  if [ "$answer" != "y" ] && [ "$answer" != "Y" ];
  then
    echo -e "\n"
    exit 0
  else
    echo -e "\n"
  fi
  # Creating pacu dir
  if [[ ! -d $pacudir ]];
  then
    mkdir -m=750 "$pacudir"
  fi
  # Creating Installation Log file
  if ! exec 3> $logpath
  then
    printf '%s\n' 'Could not create logfile. :-(' >&2')'
    exit 1
  fi
  log "$(date)"
  log "$(uname)"
  log "$(lsb_release -a)"

  log "[PACU installation started]" "print"
  log "Creating pacu binary.." "print"
  sleep 1
  #pacugui is the focus for now
  log "$(cp -rf pacugui.sh $bin/pacugui.sh && ln -fs $bin/pacugui.sh $bin/pacugui)"
  log "Installing freedups.." "print"
  sleep 1
  log "$(cp -rf third-party/freedups.sh $bin/freedups.sh && ln -fs $bin/freedups.sh $bin/freedups)"
  log "Creating configuration files in $pacudir/.." "print"
  sleep 1
  if [ -f "$pacudir/.nodes" ];
  then
    echo "There is already a node configuration file in $pacudir"
    echo "Overwrite it?"
    read -n1 -p "[y/N]" answer
    if [ "$answer" != "n" ] && [ "$answer" != "N" ];
    then
      log "`cp -rf .pacu/.nodes $pacudir ` 2>&1"
      echo -e "\n"
      log "Node configuration file overwritten." "print"
      sleep 1
    else
      echo -e "\n"
      #exit 0
    fi
  else
    log "`cp -rf .pacu/.nodes $pacudir `"
  fi
  log "Changing permissions of $pacudir" "print"
  log "`chown -R $SUDO_USER.$SUDO_USER $pacudir`"
  #log "`chown $SUDO_USER.$SUDO_USER $bin/pacugui.sh`"
  #log "`chown $SUDO_USER.$SUDO_USER $bin/pacugui`"

  log "`chmod 777 $bin/pacugui`"
  log "`chmod 755 $bin/pacugui.sh`"
  log "Checking installation.." "print"
  sleep 1
  if [ -d $pacudir ] && [ -f $bin/pacugui ];
  then
    log "PACU was successfully installed." "print"
    echo "You can view the installation log file in"
    echo "$logpath"
  else
    echo "For some reason, pacu was not installed."
    echo "Check the log in $logpath"
    echo "for further information."
  fi
}

# Beginning

if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to perform the installation."
  exit 1
else
  if [ -f $bin/pacugui ]; then
    echo "PACU is already installed."
    echo "Are you sure you want to reinstall it?"
    read -n1 -p "[y/N]" answer
    case "$answer" in
      y|Y)
        echo ""
        install
        ;;
      *)
        echo -e "\nProcess finished."
        ;;
    esac
  else
    install
  fi
fi
