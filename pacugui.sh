#!/bin/bash
INPUT=/tmp/menu.sh.$$

#Help
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

#Backup
function backup() {
  line=`grep backup_source /home/mribeirodantas/.pacu | awk -F\" {' print $2 '}`
  IFS=: read -r -a array <<<"$line"
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
         Configure) echo "Configure";;
         About) about;;
         Help) echo "Help";;
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

#Loading app
{ for I in $(seq 1 100) ; do
echo $I
sleep 0.01
done
echo 100; } | dialog --backtitle "PACS Automated Computer Utilities" \
                    --shadow --gauge "Starting.." 6 70 0
#Starts app
menu
