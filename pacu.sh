#! /bin/bash
###############################################
#	PACU 0.1
#		PACS Automated Computer Utilities
#	 _____          _       _____   ______   
#	|_   _|        / \     |_   _|.' ____ \  
#     | |         / _ \      | |  | (___ \_| 
#	  | |   _    / ___ \     | |   _.____`.  
#	 _| |__/ | _/ /   \ \_  _| |_ | \____) | 
#	|________||____| |____||_____| \______.' 
#			Copyright (c) 2013
#	<mribeirodantas at lais.huol.ufrn.br>
#	
##############################################

# Variables
PkgName=PACU_0.1_noarch
PkgVersion=v0.1

# Functions
function send()
{
echo send images
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
function help()
{
	echo "PACS Automated Computer Utilities" $PkgVersion
	echo "pacu [parameter] [option] [argument]"
	echo "Run the help for further information."
	echo "pacu --help"
}

# Beginning
case "$1" in
	--help)
		help
		;;
	-h)
		help
		;;
	*)
		help
		;;
	-s)
		send
		;;
	--send)
		send
		;;
	-q)
		query
		;;
	--query)
		query
		;;
	-p)
		plot
		;;
	--plot)
		plot
		;;
	-d)
		dump
		;;
	--dump)
		dump
		;;
	-r)
		restore
		;;
	--restore)
		restore
		;;
esac
