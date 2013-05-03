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

# Function
function install()
{
	# && will make sure it won't try
	# to link if copy fail.
	echo "Installing.."
	cp -rf pacu.sh /usr/local/bin/pacu.sh &&
	ln -fs /usr/local/bin/pacu.sh /usr/local/bin/pacu
	sleep 2
}

if [[ $EUID -ne 0 ]]; then
	echo "You must be a root user to perform the installation" 2>&1
	exit 1
else
	if [ -f /usr/local/bin/pacu ]; then
		echo "PACU is already installed." 2>&1
		echo "Are you sure you want to reinstall it?" 2>&1
		read -n1 -p "[y/N]" reply
		case "$reply" in
			y)
				echo ""
				install &&
				echo "PACU was successfully reinstalled."
				;;
			*)
				echo -e "\nProcess finished."
				;;
		esac
	else
		install &&
		echo "PACU was successfully installed."
	fi
fi
