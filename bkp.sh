#! /bin/bash

# Preparing temporary files for parsing
if [ -d /tmp/pacu ];
then
   echo `grep "backup_source" cfg` > /tmp/pacu/backupLine
else
   mkdir /tmp/pacu && echo `grep "backup_source" cfg` > /tmp/pacu/backupLine
fi

# Number of folders to back up
n=10

for i in `seq 1 $n`
do
	dir=`cat /tmp/backupLine  | cut -d " " -f$((i+1))`
	if [ "$dir" != "" ];
	then
		file=`echo $dir | gawk -F "\"" '{ print $1 }'`
		#perform not-so-far-chosen backup strategy over the file below
		echo $file
	fi
done
