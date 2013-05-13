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

# Variable
VERSION="a0.1"
ARCH="noarch"

if [ "$SUDO_USER" == "" ];
then
	SUDO_USER="`who -m | awk '{print $1;}'`"
fi

LOGPATH="/home/$SUDO_USER/.pacuLog"

# Functions

function log()
{
	echo [  `date --date=now +%r`] $1 >> $LOGPATH
	if [ "$2" == "print" ];
	then
		echo -e "$1"
	fi
}
function install()
{
	clear
	echo "pacu.$VERSION-$ARCH"
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
	# Creating Installation Log file
	date > $LOGPATH || (echo -e "Installation could not continue since it was unable to create log file\n" && exit 0)
	echo >> $LOGPATH
	uname -a >> $LOGPATH
	echo >> $LOGPATH
	lsb_release -a >> $LOGPATH
	echo >> $LOGPATH

	log "[PACU installation started]" "print"
	log "`echo Creating pacu binary..`" "print"
	sleep 1
	log "`cp -rf pacu.sh /usr/local/bin/pacu.sh && ln -fs /usr/local/bin/pacu.sh /usr/local/bin/pacu 2>&1`"
	log "`echo Installing freedups..`" "print"
	sleep 1
	log "`cp -rf third-party/freedups.sh /usr/local/bin/freedups.sh && ln -fs /usr/local/bin/freedups.sh /usr/local/bin/freedups 2>&1`"
	log "Creating configuration files in /home/$SUDO_USER/.." "print"
	sleep 1
	if [ -f /home/$SUDO_USER/.pacu ];
	then
		echo "There is already a configuration file in /home/$SUDO_USER/"
		echo "Overwrite it?"
		read -n1 -p "[y/N]" answer
		if [ "$answer" != "n" ] && [ "$answer" != "N" ];
		then
			log "`cp -rf .pacu /home/$SUDO_USER/ 2>&1`"
			echo -e "\n"
			log "Configuration file overwritten." "print"
			sleep 1
		else
			echo -e "\n"
			exit 0
		fi
	else
		log "`cp -rf .pacu /home/$SUDO_USER/ 2>&1`"
	fi
	log "Checking installation.." "print"
	sleep 1
	if [ -f /home/$SUDO_USER/.pacu ] && [ -f /usr/local/bin/pacu ];
	then
		log "PACU was successfully installed." "print"
		echo "You can view the installation log file in"
		echo "/home/$SUDO_USER/.pacuLog"
	else
		echo "For some reason, pacu was not installed."
		echo "Check the log for further information."
	fi
}

# Beginning

if [[ $EUID -ne 0 ]]; then
	echo "You must be a root user to perform the installation." 2>&1
	exit 1
else
	if [ -f /usr/local/bin/pacu ]; then
		echo "PACU is already installed." 2>&1
		echo "Are you sure you want to reinstall it?" 2>&1
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
