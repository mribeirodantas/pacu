#!/bin/bash
INPUT=/tmp/menu.sh.$$

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
#Menu
function menu() {
  dialog  --backtitle "PACS Automated Computer Utilities" \
          --title "Options" --cancel-label "Quit" \
          --ok-label "Go on" \
          --menu "Select the desired option:" 10 70 20 \
          "Take a backup" "Take a backup right now" \
          "Configure" "Configure your backup nodes" \
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
         Configure) echo "Configure";;
            Help) echo "help";;
  esac
}

#Backup
function backup() {
  line=`grep backup_source /home/mribeirodantas/.pacu | awk -F\" {' print $2 '}`
  IFS=: read -r -a array <<<"$line"
  cmd=(dialog --backtitle "PACS Automated Computer Utilities" \
              --title "Backing up nodes" --scrollbar \
              --ok-label "Go on" --cancel-label "Go back"
              --checklist "Select the folders you want to backup" 10 70 20)
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
         --menu "Select the backup strategy" 10 70 20 \
         "Full Backup" "Make an entire copy of your nodes" \
         "Incremental Backup" "Copies the changes since the last MM/DD/YY" \
         "Differential Backup" "Copies the changes comparing the last backup " 2> "${INPUT}"
  #Button click
  response=$?
  case $response in
    1)   backup;;
    255) exit 0;;
  esac
  #Menu selection
  menuitem=$(<"${INPUT}")
  case $menuitem in
    "Full Backup") full;;
    "Incremental Backup") inc;;
    "Differential Backup") diffe;;
  esac
}

#Loading app
{ for I in $(seq 1 100) ; do
echo $I
sleep 0.01
done
echo 100; } | dialog --backtitle "PACS Automated Computer Utilities" \
                    --shadow --gauge "Starting.." 6 70 0

menu
