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

# Function
function install()
{
	if [ $SUDO_USER == ""];
	then
		SUDO_USER="`who -m | awk '{print $1;}'`"
	fi

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
	echo `date` > /home/$SUDO_USER/.pacuLog || (echo -e "Installation could not continue since it was unable to create log file\n" && exit 0)
	echo "[PACU Installation started..]"

	echo "Creating binary.."
	sleep 1
	cp -rf pacu.sh /usr/local/bin/pacu.sh &&
	ln -fs /usr/local/bin/pacu.sh /usr/local/bin/pacu 2>> /home/$SUDO_USER/.paculog
	echo "Creating configuration files in /home/$SUDO_USER/.."
	sleep 1
	if [ -f /home/$SUDO_USER/.pacu ];
	then
		echo "There is already a configuration file in /home/$SUDO_USER/"
		echo "Overwrite it?"
		read -n1 -p "[y/N]" answer
		if [ "$answer" != "n" ] && [ "$answer" != "N" ];
		then
			cp -rf .pacu /home/$SUDO_USER/ 2>> /home/$SUDO_USER/.paculog
			echo -e "\nConfiguration file overwritten."
			sleep 1
		else
			echo -e "\n"
			exit 0
		fi
	else
		cp -rf .pacu /home/$SUDO_USER/ 2>> /home/$SUDO_USER/.paculog
	fi
	echo "Checking installation.."
	sleep 1
	if [ -f /home/$SUDO_USER/.pacu ] && [ -f /usr/local/bin/pacu ];
	then
		echo "PACU was successfully installed."
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
