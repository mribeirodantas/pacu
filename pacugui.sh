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

#
NODES=$HOME/.pacu/.nodes
INPUT=/tmp/pacu.$$
#Stores the dialog click response
response=
#Stores the selected values
choice=
menuselection=

#Menu
function menu() {
  dialog  --backtitle "PACS Automated Computer Utilities" \
          --title "Options" --cancel-label "Quit" \
          --ok-label "Go on" --scrollbar \
          --menu "Select the desired option:" 11 70 20 \
          "Take a backup" "Take a backup right now" \
          "Configure" "Configure your backup nodes" \
          "About" "About the toolchain" \
          "Help" "Get information on how to use pacu" 2> "${INPUT}"

  #Button click
  response=$?
  case $response in
    1)   exit 0;;
    255) exit 0;;
  esac
  #Menu selection
  menuitem=$(<"${INPUT}")
  case $menuitem in
    "Take a backup") backup;;
         Configure) configure;;
         About) about;;
         Help) echo "Help";;
  esac
}

#Backup
function backup() {
  line=`cat $HOME/.pacu/.nodes | sed '/#/ d' | gawk -F: {' print $1 '}`
  IFS=: mapfile -t array <<<"$line"
  cmd=(dialog --backtitle "PACS Automated Computer Utilities" \
              --title "Backing up nodes" --scrollbar \
              --ok-label "Go on" --cancel-label "Go back"
              --checklist "Select the folders you want to backup" 11 70 20)
  i=0 n=${#cmd[*]}

  #Menu selection
  for f in "${array[@]}"; do
    cmd[n++]=$((i++)); cmd[n++]="$f"; cmd[n++]=""
  done
  choice=$("${cmd[@]}" 2>&1 >/dev/tty)

  #Button click
  response=$?
  case $response in
    0)strategy;;
    1)menu;;
    255) exit 0;;
  esac
}

function strategy() {
  dialog --backtitle "PACS Automated Computer Utilities" \
         --title "Backing up nodes" --scrollbar \
         --ok-label "Go on" --cancel-label "Go back" \
         --menu "Select the backup strategy" 11 70 20 \
         "Full Backup" "Make an entire copy of your nodes" \
         "Incremental Backup" "Copies the changes since the last MM/DD/YY" \
         "Differential Backup" "Copies the changes comparing the last backup" \
         "Mirroring" "Mirrors a copy of the backup remotely" 2> "${INPUT}"
  #Button click
  response=$?
  case $response in
    0)
    #Menu selection
    if [[ "$response" != 1 ]];
    then
      menuitem=$(<"${INPUT}")
      case $menuitem in
        "Full Backup") full;;
        "Incremental Backup") inc;;
        "Differential Backup") diffe;;
        "Mirroring") mirror;;
      esac
    fi;;
    1)   backup;;
    255) exit 0;;
  esac
}

#Full Backup
function full() {
  echo "Full backup"
  # Do the Backup
  echo "Here's the file you chose:"
  for cho in $choice;
  do
    ls -ld -- "${array[cho]}"
  done
}
#Incremental Backup
function inc() {
  echo "Incremental Backup"
}

#Differential Backup
function diffe() {
  echo "Differential backup"
}

#Configure back up
function configure() {
  line=`cat $HOME/.pacu/.nodes | sed '/#/ d' | gawk -F: {' print $1 '}`
  IFS=: mapfile -t array <<<"$line"
  cmd=(dialog --backtitle "PACS Automated Computer Utilities" \
              --title "Configuring nodes" --scrollbar \
              --ok-label "Add node"  \
              --cancel-label "Go back"
              --extra-button --extra-label "Alter node" \
              --checklist "Select the folders you want to alter" 11 70 20)
  i=0 n=${#cmd[*]}

  #Menu selection
  for f in "${array[@]}"; do
    cmd[n++]=$((i++)); cmd[n++]="$f"; cmd[n++]=""
  done
  choice=$("${cmd[@]}" 2>&1 >/dev/tty)

  #Button click
  response=$?
  case $response in
    0)FILEA=$(dialog --title "Directory to track" --title "Please choose the dir to back up" --dselect / 8 40 2>&1 >/dev/tty);
      FILEB=$(dialog --title "Target directory" --title "Please choose a place to store your backup" --dselect / 14 48 2>&1 >/dev/tty);
      dialog --backtitle "PACS Automated Computer Utilities" \
        --title "Backing up nodes" --scrollbar \
        --ok-label "Go on" --cancel-label "Go back" \
        --menu "Select the backup strategy" 11 70 20 \
        "Full Backup" "Make an entire copy of your nodes" \
        "Incremental Backup" "Copies the changes since the last MM/DD/YY" \
        "Differential Backup" "Copies the changes comparing the last backup" \
        "Mirroring" "Mirrors a copy of the backup remotely" 2> "${INPUT}"
      #Button click
      response=$?
      case $response in
        0)
          #Menu selection
          if [[ "$responseb" != 1 ]];
          then
            menuitem=$(<"${INPUT}")
            case $menuitem in
              "Full Backup") BKPTYPE="F";;
              "Incremental Backup") BKPTYPE="I";;
              "Differential Backup") BKPTYPE="D";;
              "Mirroring") BKPTYPE="M";;
            esac
          fi
          echo "$FILEA":"$FILEB":"$BKPTYPE"::: >> $NODES
          ;;
          1)   backup;;
          255) exit 0;;
          esac
        ;;
    2|3)echo "Alter"
      ;;
    1)menu;;
    255) exit 0;;
  esac
}

#About
function about() {
  dialog  --backtitle "PACS Automated Computer Utilities" \
          --title "About" --ok-label "Go back" \
          --msgbox "PACS Automated Computer Utilities, pacu, is developed by \
                    Marcel Ribeiro Dantas <mribeirodantas@lais.huol.ufrn.br> \
                    at the Laboratory of Technological Innovation in Healthcare\
                    LAIS-HUOL-UFRN." 8 65
  #Button click
  response=$?
  case $response in
    0)  menu;;
    1)  exit 0;;
    255)  exit 0;;
  esac
}

#Loading app
{ for I in $(seq 1 100) ; do
echo $I
sleep 0.01
done
echo 100; } | dialog --backtitle "PACS Automated Computer Utilities" \
                    --shadow --gauge "Starting.." 6 70 0
#Starts app
menu
