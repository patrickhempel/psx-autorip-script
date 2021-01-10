#!/bin/bash

# Defining variables for later use
SOURCEDRIVE="$1"
SCRIPTROOT="$(dirname $(realpath $0))"
CACHE="$(awk '/^cache/{print $1}' $SCRIPTROOT/settings.cfg | cut -d '=' -f2)"
DEBUG="$(awk '/^debug/{print $1}' $SCRIPTROOT/settings.cfg | cut -d '=' -f2)"
MINLENGTH="$(awk '/^minlength/{print $1}' $SCRIPTROOT/settings.cfg | cut -d '=' -f2)"
OUTPUTDIR="$(awk '/^outputdir/' $SCRIPTROOT/settings.cfg | cut -d '=' -f2 | cut -f1 -d"#" | xargs)"
ARGS=""

# Check if the source drive has actually been set and is available
if [ -z "$SOURCEDRIVE" ]; then
	echo "ERROR: Source Drive is not defined."
	echo "When calling this script manually, make sure to pass the drive path as a variable: ./autorip.sh [DRIVE]"
	exit 1
fi
setcd -i "$SOURCEDRIVE" | grep --quiet 'Disc found'
if [ $? -ne 0 ]; then
        echo "$SOURCEDRIVE: ERROR: Source Drive is not available."
        exit 1
fi

# Construct the arguments for later use
if [ -d "$OUTPUTDIR" ]; then
	:
else
	echo "[ERROR]: The output directory specified in settings.conf is invalid!"
	exit 1
fi
if [ -d "$SCRIPTROOT/logs" ]; then
	:
else
	echo "[ERROR]: Log directory under $SCRIPTROOT/logs is missing!"
	exit 1
fi

if [ -z "$CACHE" ]; then
	if [ "$CACHE" = "-1" ]; then
		break
	elif [[ "$CACHE" =~ '^[0-9]+$' ]]; then
		ARGS="--cache=$CACHE"
	fi
fi
if [ "$DEBUG" = "true" ]; then
	ARGS=$(echo "$ARGS --debug")
fi
if [[ "$MINLENGTH" =~ '^[0-9]+$' ]]; then
	ARGS=$(echo "$ARGS --minlength=$MINLENGTH")
else
	ARGS=$(echo "$ARGS --minlength=0")
fi

# Match unix drive name to Make-MKV drive number and check it
SOURCEMMKVDRIVE=$(makemkvcon --robot --noscan --cache=1 info disc:9999 | grep "$SOURCEDRIVE" | grep -o -E '[0-9]+' | head -1)
if [ -z "$SOURCEMMKVDRIVE" ]; then
	echo "$SOURCEDRIVE: ERROR: Make-MKV Source Drive is not defined."
	exit 1
fi

echo "$SOURCEDRIVE: Started ripping process"

#Extract DVD Title from Drive

DISKTITLERAW=$(sleep 5 && blkid -o value -s LABEL $SOURCEDRIVE && sleep 5)
DISKTITLERAW=${DISKTITLERAW// /_}
NOWDATE=$(date +"%Y%m%d-%k%M%S")
DISKTITLE=$(echo "${DISKTITLERAW}_-_$NOWDATE")


mkdir $OUTPUTDIR/$DISKTITLE
makemkvcon mkv --messages=$SCRIPTROOT/logs/$NOWDATE.log --noscan --robot $ARGS disc:$SOURCEMMKVDRIVE all $OUTPUTDIR/$DISKTITLE
echo "$SOURCEDRIVE: Ripping finished, ejecting"
eject $SOURCEDRIVE
