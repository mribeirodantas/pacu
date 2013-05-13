#!/bin/bash
# Freedups will free up space by hardlinking identical files together.
# Copyright 2001, William Stearns <wstearns@pobox.com>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 59 Temple
# Place - Suite 330, Boston, MA 02111-1307, USA.

#From the yet-another-program-that-should-have-been-written-in-a-real-language series.

#FIXME - keep counts of why links not made?  Only catches first reason...
#FIXME - NOTE Presettable parameters (place on command line before freedups): no longer available.

SPACESAVED=0
SPACEWOULDHAVESAVED=0

LinkFiles () {
#Parameters: the 2 files that need to be hardlinked together.
#To support more than 2 file parameters, revert the "link to older file" logic to this loop.
#FIRSTFILE="$1"
#shift
#for OTHERFILE in "$@" ; do
#	...
#done
	NoDebug '++++' lf "$@"
	if [ $# -lt 2 ]; then
		return 1
	fi
#The "find -type f" above already does this check.
#	for AFILE in "$@" ; do
#		if [ ! -f "$AFILE" ]; then
#			Debug $AFILE is not a file, aborting link.
#			return 1
#		fi
#	done
	FILESIZE=`ls -al "$1" | awk '{print $5}'`
	if [ "$1" -nt "$2" ]; then
		#$1 is newer than $2; link to the older ($2) file
		FIRSTFILE="$2"
		OTHERFILE="$1"
	elif [ "$2" -nt "$1" ]; then
		FIRSTFILE="$1"
		OTHERFILE="$2"
	elif [ `ls -al "$2" | awk '{print $2}'` -gt `ls -al "$1" | awk '{print $2}'` ]; then
		#If $2 has more links than $1
		NoDebug "$2" has more links
		FIRSTFILE="$2"
		OTHERFILE="$1"
	else
		NoDebug $1 has more links or equal
		FIRSTFILE="$1"
		OTHERFILE="$2"
	fi
	#FIXME - use least number of fragments as an additional way to decide which is firstfile.
	if [ "$ACTUALLYLINK" = "YES" ]; then
		if [ "$PARANOID" = "YES" ]; then
			ls -ali "$FIRSTFILE" "$OTHERFILE" >/dev/stderr
			echo "Press enter to link or Ctrl-C to abort" >/dev/stderr
			read JUNK </dev/stderr
		fi
		#FIXME - askfirst if CLP requests it.
		#FIXME - invoke sudo if not root and either file or either parent dir not owned by this user
		if ln -f "$FIRSTFILE" "$OTHERFILE" ; then		#Hardlink takes care of time, owner, and rights.
			echo $FILESIZE Linked "$FIRSTFILE" and "$OTHERFILE"
			SPACESAVED=$[ $SPACESAVED + $FILESIZE ]
		else
			echo $FILESIZE: Failed to link "$FIRSTFILE" and "$OTHERFILE"
			SPACEWOULDHAVESAVED=$[ $SPACEWOULDHAVESAVED + $FILESIZE ]
		fi
	else
		echo $FILESIZE: Would have linked "$FIRSTFILE" and "$OTHERFILE"
		SPACEWOULDHAVESAVED=$[ $SPACEWOULDHAVESAVED + $FILESIZE ]
	fi
}

FilesShouldBeLinked () {
#Parameters - the two files to be compared, and their basenames (file1, file2, base1, base2)
#Returns 0 (True) if contents identical.
#If shouldn't be linked (different in any way, already share an inode, etc), >0 (False)
	#if [ "$1" = "$2" ]; then	#Caught by shared inode test below
	#	NoDebug $1 and $2 are the same file.		; return 1
#Commented sections have been handled by upper levels.
	#elif [ ! -f "$1" ]; then
	#	Debug "$1" is not a file.			; return 2
	#elif [ ! -f "$2" ]; then
	#	Debug "$2" is not a file.			; return 2
	#elif [ ! -s "$1" ]; then
	#	Debug "$1" has zero length.			; return 3
	#elif [ ! -s "$2" ]; then
	#	Debug "$2" has zero length.			; return 3
	if [ "$1" -ef "$2" ]; then
		#NoDebug "$1" and "$2" already share an inode.
		return 4
	elif [ ! -r "$1" ] || [ ! -r "$2" ]; then
		#NoDebug "$1" or "$2" can\'t be read.
		return 5
	elif [ "$DATESEQUAL" = "YES" ] && [ "$1" -nt "$2" ]; then
		#NoDebug "$1" is newer than "$2"
		return 6
	elif [ "$DATESEQUAL" = "YES" ] && [ "$1" -ot "$2" ]; then
		#NoDebug "$1" is older than "$2"
		return 6
	#elif [ `ls -al "$1" | awk '{print $5 "/" $1 "/" $3 "/" $4 }'` != `ls -al "$2" | awk '{print $5 "/" $1 "/" $3 "/" $4 }'` ]; then
	#	NoDebug "$1" and "$2" differ in size, rights, or ownership. ; return 7
	elif [ "$FILENAMESEQUAL" = "YES" ] && [ "$3" != "$4" ]; then
		#NoDebug "$1" and "$2" have different filenames.
		return 8
	elif ! diff -q "$1" "$2" >/dev/null ; then
		#NoDebug "$1" and "$2" have different contents.
		return 9
	else
		#NoDebug Identical.
		return 0
	fi
}


if type -path basename >/dev/null 2>/dev/null ; then
	THISSCRIPT=`basename $0`
else
	THISSCRIPT="$0"
fi

#FIXME - update
ShowHelpAndExit () {
	echo Usage: >/dev/stderr
	echo $THISSCRIPT '[options] DirectoriesToSearch' >/dev/stderr
	echo Options: >/dev/stderr
	echo '-a|--actuallylink=yes' >/dev/stderr
	echo "    Actually link the files.  Otherwise, just report on potential savings." >/dev/stderr
	echo '-d|--datesequal=yes' >/dev/stderr
	echo "    Require that the modification dates and times be equal before linking." >/dev/stderr
# --debug is hidden.
#	echo '-e FilespecToExclude' >/dev/stderr
#	echo '--exclude FilespecToExclude' >/dev/stderr
#	echo "    Exclude files matching this regular expression." >/dev/stderr
	echo '-f|--filenamesequal=yes' >/dev/stderr
	echo "    Require that the two (pathless) filenames be equal before linking." >/dev/stderr
	echo '-h|--help' >/dev/stderr
	echo "    Show this help." >/dev/stderr
	echo '-m MinimumFileSize' >/dev/stderr
	echo '--minsize=MinimumFileSize' >/dev/stderr
	echo "    Only consider files larger than this number of bytes." >/dev/stderr
	echo '-p|--paranoid=yes' >/dev/stderr
	echo "    Show directory listing of candidates and wait before linking." >/dev/stderr
	echo "    This only has an effect if actually linking files." >/dev/stderr
	echo Examples: >/dev/stderr
	echo $THISSCRIPT '/usr/src/linux-*' >/dev/stderr
	echo '    Report on what files could be linked under any kernel source trees,' >/dev/stderr
	echo '    but do not link them.' >/dev/stderr
	echo $THISSCRIPT '-a /usr/src/linux-*' >/dev/stderr
	echo '    Link identical files in those trees.' >/dev/stderr
	echo $THISSCRIPT '-a --datesequal=yes -f /usr/doc /usr/share/doc' >/dev/stderr
	echo '    Be more strict; the modification time and filename need to be equal' >/dev/stderr
	echo '    before two files can be linked.' >/dev/stderr
	echo $THISSCRIPT '--actuallylink=yes -m 1000 /usr/src/linux-* /usr/src/pcmcia-*' >/dev/stderr
	echo '    Only link files with 1001 or more bytes.' >/dev/stderr
	exit 1
} #End of ShowHelpAndExit

#Carry over VERBOSE -> PARANOID, CHECKDATE -> DATESEQUAL, in case anyone's still using v0.2.1 method
#of setting environment variables.
if [ "$VERBOSE" = "YES" ]; then
	PARANOID="YES"
fi
if [ "$CHECKDATE" = "YES" ]; then
	DATESEQUAL="YES"
fi

#Parse for parameters
until [ -z "$*" ]; do
	case `echo $1 | tr a-z A-Z` in
	-A|--ACTUALLYLINK|--ACTUALLYLINK=YES)
		ACTUALLYLINK=YES	
		shift	;;
	--DEBUG|--DEBUG=YES)
		DEBUG=YES
		shift	;;
	-D|--DATESEQUAL|--DATESEQUAL=YES)
		DATESEQUAL=YES
		shift	;;
	-F|--FILENAMESEQUAL|--FILENAMESEQUAL=YES)
		FILENAMESEQUAL=YES
		shift	;;
	-H|--HELP)
		ShowHelpAndExit
		shift	;;
	-M)
		if [ "z$2" != "z" ] && [ $[ $2 ] -gt 0 ]; then
			MINSIZE=$[ $2 ]
			shift
		else
			echo Positive number argument required for "$1".  Exiting. >/dev/stderr
			exit 1
		fi
		shift	;;
	--MINSIZE=*)
		#MINSIZE=$[ `echo $1 | sed -e s/.*=//` ]	#Let's not use sed; one more utility to require.
		MINSIZE=$[ ${1##*=} ]	#Stuff following "="
		if [ $MINSIZE -le 0 ]; then
			echo Positive number argument required for "$1".  Exiting. >/dev/stderr
			exit 1
		fi
		shift	;;
	-P|--PARANOID|--PARANOID=YES)
		PARANOID=YES
		shift	;;
#	-E)
#		#FIXME - implement
#		shift	;;
#	--EXCLUDE=*)
#		#FIXME - implement
#		shift	;;
	*)
		if [ -e "$1" ]; then	#Dirs and files are all valid.  Device nodes, links, and pipes will get stripped by find.
			DIRS="$DIRS $1"
		else
			echo "$1" is not recognized as a valid command line option or >/dev/stderr
			echo directory.  Please use \"$THISSCRIPT --help\" for a summary. >/dev/stderr
			exit 1
		fi
		shift	;;
	esac
done

#The choice of which version of this function to use depends on
#whether FILENAMESEQUAL=YES or not.  DO NOT move the following
#function declaration above the preceding block which actually
#sets FILENAMESEQUAL.

if [ "$FILENAMESEQUAL" = "YES" ]; then
	ProcessSameSignatureFiles () {
		#NoDebug '----' pssf "$@"
		for ONEFILE in "$@" ; do
			ONEBASE="`basename "$ONEFILE"`"
			#The following shift compares each file to each other once without comparing a file to itself.
			shift
			for TWOFILE in "$@" ; do
				if FilesShouldBeLinked "$ONEFILE" "$TWOFILE" "$ONEBASE" "`basename "$TWOFILE"`" ; then
					LinkFiles "$ONEFILE" "$TWOFILE"
				fi
			done
		done
	}
else
	ProcessSameSignatureFiles () {
		#NoDebug '----' pssf "$@"
		for ONEFILE in "$@" ; do
			#The following shift compares each file to each other once without comparing a file to itself.
			shift
			for TWOFILE in "$@" ; do
				if FilesShouldBeLinked "$ONEFILE" "$TWOFILE" "" "" ; then
					LinkFiles "$ONEFILE" "$TWOFILE"
				fi
			done
		done
	}
fi

if [ "$DEBUG" = "YES" ]; then
	Debug () {
		echo $* >/dev/stderr
	}
else
	Debug () {
		:
	}
fi
NoDebug () {
	:
}

if [ -z "$DIRS" ]; then
	ShowHelpAndExit
fi
echo -n "Options chosen: " >/dev/stderr
if [ "$ACTUALLYLINK" = "YES" ]; then 	echo -n "ActuallyLink " >/dev/stderr ; 		fi
if [ "$DEBUG" = "YES" ]; then 		echo -n "Debug " >/dev/stderr ; 		fi
if [ "$DATESEQUAL" = "YES" ]; then 	echo -n "DatesEqual " >/dev/stderr ; 		fi
if [ -n "$EXCLUDE" ]; then 		echo -n "Exclude=$EXCLUDE " >/dev/stderr ; 	fi
if [ "$FILENAMESEQUAL" = "YES" ]; then 	echo -n "FileNamesEqual " >/dev/stderr ; 	fi
if [ -n "$MINSIZE" ]; then 		echo -n "MinSize=$MINSIZE " >/dev/stderr ; 	fi
if [ "$PARANOID" = "YES" ]; then 	echo -n "Paranoid " >/dev/stderr ; 		fi

if [ -z "$ACTUALLYLINK$DEBUG$DATESEQUAL$EXCLUDE$FILENAMESEQUAL$MINSIZE$PARANOID" ]; then
	echo -n "None " >/dev/stderr
fi
echo >/dev/stderr

echo Checking for files to link in $DIRS >/dev/stderr

#/tmpsizes will hold lines like: 
#1184/644/0/0 /tmp/bkwrap
#	or
#1184/644/0/0/"bkwrap" /tmp/bkwrap
#if FILENAMESEQUAL="YES" - once I fix it so spaces in the filenames aren't a problem.

#Pipe find directly into while read; use exec kludge or manual looping; straight piping causes last file size block to be skipped from no GT1 var.
#FIXME - I can't find the quoting to handle files with spaces in the names.
#update: The read will work correctly if the filename spacs are backslash escaped.
#if [ "$FILENAMESEQUAL" = "YES" ]; then
#	EQUIVPRINTF='%s/%m/%U/%G/"%f" %p\n'
#else
	EQUIVPRINTF='%s/%m/%U/%G %p\n'
#fi

trap 'rm -f $SIGFILE' 0
NoTempFile () {
#Handle the case where the temp file can't be created for some reason.
	echo Couldn\'t create $1 temp file, exiting.
	exit 1
}

if type -path mktemp >/dev/null 2>/dev/null ; then
	SIGFILE=`mktemp -q /tmp/signatures.XXXXXX` || NoTempFile /tmp/signatures
else
	echo 'Warning!  This system does not have the mktemp utility.  Please' >/dev/stderr
	echo 'install it. ' >/dev/stderr
	SIGFILE=/tmp/signatures.$$.$RANDOM
	if [ -e "$SIGFILE" ]; then
		NoTempFile $SIGFILE
	else
		touch $SIGFILE
	fi
fi

if ! type -path md5sum >/dev/null 2>/dev/null ; then
	echo Missing md5sum, please install.
	exit 1
fi


find $DIRS -xdev -type f `if [ -n "$MINSIZE" ]; then echo "-a -size +${MINSIZE}c" ; fi` -printf "$EQUIVPRINTF" \
| grep -v '^0/' | sort -nr | (while read SIGNATURE FILENAME ; do echo $SIGNATURE/`md5sum "$FILENAME"` ; done ) \
| sort -nr | uniq >$SIGFILE

#Can't use: sed -e "s@\(.*\)/MD5SUM \(.*\)@\1/`md5sum \1` \2@"
#because the \1 is only replaced by sed itself, not the shell.

#FIXME - grep out exclude list if $EXCLUDE set
while read SIGNATURE FILENAME ; do
	#NoDebug Z $SIGNATURE Z $FILENAME Z
	if [ "$SIGNATURE" = "$OLDSIGNATURE" ]; then
		SAMESIGNATUREFILES="$SAMESIGNATUREFILES \"$FILENAME\""
		NUMFILES="GT1"
	else
		if [ "$NUMFILES" = "GT1" ]; then
			#NoDebug $SAMESIGNATUREFILES have the same signature.
			eval ProcessSameSignatureFiles $SAMESIGNATUREFILES
			#ZZZZ - in progress, not functional.
			#( for SOMEFILE in $SAMESIGNATUREFILES ; do
			#	md5sum "$SAMESIGNATUREFILES"
			#done ) | sort -nr | (
			#	OLDCHECKSUM=""
			#	OLDSIGGEDFILE=""
			#	while read CHECKSUM SIGGEDFILE
			#		#ZZZZ
			#	done
			#)
		fi
		SAMESIGNATUREFILES="\"$FILENAME\""
		NUMFILES="1"
	fi
	OLDSIGNATURE="$SIGNATURE"
	OLDFILENAME="$FILENAME"
done <$SIGFILE
if [ "$NUMFILES" = "GT1" ]; then	#Handle last file signature.
	#NoDebug $SAMESIGNATUREFILES have the same signature.
	eval ProcessSameSignatureFiles $SAMESIGNATUREFILES
fi

if [ $SPACESAVED -gt 0 ]; then
	echo Total space saved: $SPACESAVED \(Small risk of overcounting space saved if linked files have different times.\)
fi
if [ $SPACEWOULDHAVESAVED -gt 0 ]; then
	echo Total space would have saved: $SPACEWOULDHAVESAVED \(An overestimate if more than two files would have been linked together.\)
fi
exit

#Read kludge:
#Redirect stdin to work around an f^@&ing annoying limitation in the read command.
#CKPTSORTRULEFILE=" sortrulefile: split into equivalent sections." ; #ckpt $CKPTSORTRULEFILE
#exec 5<&0 < "$ONEFILE"
#while read ONELINE ; do
#	NEWRULETAG="`ruletag $ONELINE`"
#	if [ "$NEWRULETAG" != "$LASTRULETAG" ]; then
#		FILECOUNT=$[ $FILECOUNT + 1 ]
#		if [ -f $ONEFILE.$FILECOUNT ]; then rm -f $ONEFILE.$FILECOUNT || logfail $LINENO masonlib: YYYY 0118 ; fi
#	fi
#	echo "$ONELINE" >>$ONEFILE.$FILECOUNT
#	LASTRULETAG="$NEWRULETAG"
#done
#exec 0<&5 5<&-


