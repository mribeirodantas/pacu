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

# Variables
PkgName=PACU_0.1_noarch
PkgVersion=v0.1

# Functions
function send()
{
echo "send images"
}

function query()
{
echo query images
}
function plot()
{
echo plot dicom images
}
function dump()
{
echo dump PACS db
}
function restore()
{
echo restore PACS db
}
function miss()
{
	echo "PACS Automated Computer Utilities" $PkgVersion
	echo "pacu [parameter] [option] [argument]"
	echo "Run the help for further information."
	echo "pacu --help"
}
function help()
{
	echo "PACS Automated Computer Utilities" $PkgVersion
	echo "pacu [parameter] [option] [argument]"
	echo -e "\nParameters\n"
	echo "	-s --send	Send images to a PACS Server"
	echo "	-q --query	Query images from a PACS Server"
	echo "	-d --dump	Dump the PACS Server database"
	echo "	-r --restore	Restore the PACS Server database"
	echo "	-h --help	Display this help"
	echo -e "\nOptions\n"
}
# Beginning
case "$1" in
	-s|--send)
		send
		;;
	-q|--query)
		query
		;;
	-p|--plot)
		plot
		;;
	-d|--dump)
		dump
		;;
	-r|--restore)
		restore
		;;
	-h|--help)
		help
		;;
	*)
		miss
		;;
esac
