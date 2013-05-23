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

#Variables
#Node config path
nodesFile=$HOME/.pacu/.nodes

#Choose a directory
function chooseDir() {
  FILE=$(dialog --title "Directory to track" \
       --title "$1" --dselect "$2" 10 50 2>&1 >/dev/tty)
  echo $FILE
}

#Choosing a node
function chooseMNode() {
  node=`cat $nodesFile | sed '/#/ d' | gawk -F: {' print $1 '}`
  IFS=: mapfile -t array <<<"$node"
  cmd=(dialog --backtitle "PACS Automated Computer Utilities" \
              --scrollbar \
              --ok-label "Choose"  \
              --cancel-label "Go back" \
              --checklist "$1" 11 70 20)
  i=0 n=${#cmd[*]}

  #Menu selection
  for f in "${array[@]}"; do
    cmd[n++]=$((i++)); cmd[n++]="$f"; cmd[n++]=""
  done
  choice=$("${cmd[@]}" 2>&1 >/dev/tty)
  clickResponse=$?
  case $clickResponse in
    0) for cho in $choice;
       do
         echo ${array[cho]}
       done;;
    1) echo "back";;
  255) exit 1;;
  esac
}

function backupType() {
  cmd=$(dialog --backtitle "PACS Automated Computer Utilities" \
         --title "Backing up nodes" --scrollbar \
         --ok-label "Go on" --cancel-label "Go back" \
         --menu "Select the backup strategy" 11 70 20 \
         "Full Backup" "Make an entire copy of your nodes" \
         "Incremental Backup" "Copies the changes since the last MM/DD/YY" \
         "Differential Backup" "Copies the changes comparing the last backup" \
         "Mirroring" "Mirrors a copy of the backup remotely" 2>&1 >/dev/tty)
  #Button click
  clickResponse=$?
  case $clickResponse in
    0)
    #Menu selection
    if [[ "$clickResponse" != 1 ]];
    then
      case $cmd in
        "Full Backup") echo "F";;
        "Incremental Backup") echo "I";;
        "Differential Backup") echo "D";;
        "Mirroring") echo "M";;
      esac
    fi;;
    1)   menu;;
    255) exit 0;;
  esac
}

#messageBox
#Usage: (messageBox "title" "text" "function to go back")
function messageBox() {
  (dialog  --backtitle "PACS Automated Computer Utilities" \
          --title "$1" --ok-label "Go back" \
          --msgbox "$2" 8 65)

  #Button click
  clickResponse=$?
  case $clickResponse in
    0)  $3;;
    1)  exit 0;;
    255)  exit 0;;
  esac
}

#Add
function add() {
source=$(chooseDir "Choose the directory to track" "/")
#Do the source path exist?
if [[ ! -d $source ]];
then
  messageBox "Error!" "The path $source does not exist." "menu"
fi
target=$(chooseDir "Where do you want to place the backup?" "/")
#Do the target path exist?
if [[ ! -d $target ]];
then
  messageBox "Error!" "The path $target does not exist." "menu"
fi
strategy=$(backupType)

#Is there already a backup node within this source path?
#For now, you cant backup /home/ if you backuped /home/username(issue)
#But you can do it the other way around
if grep "^$source" "$nodesFile"
then
  messageBox "Error!" "There is already a backup node within $source" "menu";
else
  echo "$source":"$target":"$strategy":"NEVER":: >> "$nodesFile" && messageBox "Congratulations!" "$source -> $target ($strategy) was added successfully" "menu";
fi
}

#List node
function list() {
  nLines=$(cat $nodesFile | sed '/#/ d' | wc -l 2>&1)
  for ((i=1; i<=$nLines; ++i )) ;
  do
    nodeSource[$i]=`cat $nodesFile | sed '/#/ d' |  sed -n "$i p" | gawk -F: {' print $1 '}`
    nodeTarget[$i]=`cat $nodesFile | sed '/#/ d' |  sed -n "$i p" | gawk -F: {' print $2 '}`
    backupType[$i]=`cat $nodesFile | sed '/#/ d' |  sed -n "$i p" | gawk -F: {' print $3 '}`
    lastFullBkp[$i]=`cat $nodesFile | sed '/#/ d' |  sed -n "$i p" | gawk -F: {' print $4 '}`
  done
  for ((i=1; i<=$nLines; ++i )) ; 
  do
    #TODO: Dialog for showing that
    echo "--------------------------------------------" >>/tmp/list.$$
    echo "Source: ${nodeSource[$i]}" >>/tmp/list.$$
    echo "Target: ${nodeTarget[$i]}" >>/tmp/list.$$
    echo "Type of Backup: ${backupType[$i]}" >>/tmp/list.$$
    echo "Last Full Backup: ${lastFullBkp[$i]}" >>/tmp/list.$$
  done
  echo "--------------------------------------------" >>/tmp/list.$$
  (dialog --scrollbar --exit-label "Go back" --textbox /tmp/list.$$ 25 40)
  #Cleaning information, in case user wants to view it again
  echo > /tmp/list.$$
  menu
}

#Remove node
function remove() {
  nodes=$(chooseMNode "Select the nodes to remove")
  if [[ "$nodes" == "" ]]
  then
    messageBox "Warning!" "You haven't selected any node" "menu"
    return
  elif [[ "$nodes" == "back" ]]
  then
    manage
  else
    grep -v "^${nodes[cho]}" "$nodesFile" > /tmp/nodes.$$ &&
    mv /tmp/nodes.$$ $nodesFile &&
    if [[ $(echo "${nodes[@]}" | wc -l) -gt '1' ]];
    then
      messageBox "It's done!" "${nodes[cho]} were removed successfully" "menu";
    else
      messageBox "It's done!" "${nodes[cho]} was removed successfully" "menu";
    fi
  fi
}

#Manage
function manage() {
  cmd=$(dialog  --backtitle "PACS Automated Computer Utilities" \
          --title "Managing Nodes" --cancel-label "Go back" \
          --ok-label "Go on" --scrollbar \
          --menu "What do you want to do?" 13 60 20 \
          "List" "List nodes" \
          "Edit" "Edit node configuration" \
          "Remove" "Stop tracking a node" 2>&1 >/dev/tty)

  #Button click
  clickResponse=$?
  case $clickResponse in
    0)#Menu selection
      case $cmd in
        List) list;;
        Remove) remove;;
        Edit) echo "edit";;
      esac;;
    1) menu;;
    255) exit 0;; # Escape
  esac


}

#About
function about() {
  (messageBox "About" "PACS Automated Computer Utilities, PACU, is developed by \
                    Marcel Ribeiro Dantas <mribeirodantas@lais.huol.ufrn.br> \
                    at the Laboratory of Technological Innovation in Healthcare\
                    LAIS-HUOL-UFRN." "menu")
}
#Menu window
function menu() {
  cmd=$(dialog  --backtitle "PACS Automated Computer Utilities" \
          --title "PACU Options" --cancel-label "Quit" \
          --ok-label "Go on" --scrollbar \
          --menu "What do you want to do?" 13 60 20 \
          "Back Up" "Take a backup right now" \
          "Add" "Add a new node to PACU" \
          "Manage" "Manage your backup nodes" \
          "About" "About the toolchain" \
          "Help" "Get information on how to use PACU" 2>&1 >/dev/tty)

  #Button click
  clickResponse=$?
  case $clickResponse in
    1)   exit 0;; # Quit
    255) exit 0;; # Escape
  esac

  #Menu selection
  case $cmd in
    "Back Up") backup;;
    Add) add;;
    Manage) manage;;
    About) about;;
    Help) echo "Help";;
  esac
}

#Loading script
#Nice effect for Gnome users
if $(ps aux|grep /usr/bin/gnome-shell | sed '/--color/ d' 2>&1 /dev/null); then notify-send "Thanks for using PACU"; fi
{ for i in $(seq 1 100) ; do
echo $i
sleep 0.01
done
echo 100; } | dialog --backtitle "PACS Automated Computer Utilities" \
                    --shadow --gauge "Loading data.." 6 70 0
#Starts script
menu
