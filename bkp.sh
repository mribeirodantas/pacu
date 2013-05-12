#! /bin/bash

# 

if [ "$SUDO_USER" == "" ];
then
   SUDO_USER="`who -m | awk '{print $1;}'`"
fi

# Preparing temporary files for parsing
if [ -d /tmp/pacu ];
then
   echo `grep "backup_source" /home/$SUDO_USER/.pacu` > /tmp/pacu/backupLine
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
		echo "Backing up $file.."
		sleep 1
		tar zcf $(basename $file)-`date +%Y%m%d`.tar.gz $file
	fi
done
tar zcf backup-full-`date +%Y%m%d`.tar.gz --remove-files *-`date +%Y%m%d`.tar.gz && echo "The backup process is finished." && exit 0
echo "There was an error and the backup process could not finish properly."
