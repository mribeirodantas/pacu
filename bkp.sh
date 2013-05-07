#! /bin/bash

# Preparing temporary files for parsing
if [ -d /tmp/pacu ];
then
   echo `grep "backup_source" cfg` > /tmp/pacu/backupLine
else
   mkdir /tmp/pacu && echo `grep "backup_source" cfg` > /tmp/pacu/backupLine
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
		#perform not-so-far-chosen backup strategy over the file below
		echo $file
	fi
done
