#! /bin/bash
###############################################
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
##############################################

# Variable

# Function
function install()
{
	cp -rf pacu.sh /usr/local/bin/pacu.sh
	ln -fs /usr/local/bin/pacu.sh /usr/local/bin/pacu
}

if [[ $EUID -ne 0 ]]; then
	echo "You must be a root user to perform the installation" 2>&1
	exit 1
else
	if [ -f /usr/local/bin/pacu ]; then
		echo "PACU is already installed." 2>&1
		echo "Are you sure you want to install over?" 2>&1
		read -n1 -p "[y/N]" reply
		case "$reply" in
			y*)
				echo -e "\nInstalando.."
				sleep 2
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
