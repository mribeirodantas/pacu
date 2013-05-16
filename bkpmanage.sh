#!/bin/bash

{ for I in $(seq 1 100) ; do
echo $I
sleep 0.01
done
echo 100; } | dialog --shadow --gauge "Loading backup manager.." 6 70 0

# File or Directory selection menu with dialog
fileroot=$1
array=( $(ls $fileroot) )

dialog --title "Select a directory to back up" --scrollbar --checklist \
  "Choose one of the following or press to exit" \
  20 50 20 ${array[@]} 2> /tmp/$$

if [ $? -gt 0 ]; then
  rm -f /tmp/$$  rm -f /tmp/$$
  clear
  echo "Interrupted"
  exit 0
fi

arrayb=( $(cat /tmp/$$) )
for i in arrayb
do
  echo "${arrayb[@]}" > a
  echo "${arrayb[@]}"
done
