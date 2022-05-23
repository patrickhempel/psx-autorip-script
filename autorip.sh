#!/bin/bash

# Defining variables for later use
SOURCEDRIVE="$1"
SCRIPTROOT="$(dirname """$(realpath "$0")""")"
OUTPUTDIR="$(awk '/^outputdir/' "$SCRIPTROOT/settings.cfg" | cut -d '=' -f2 | cut -f1 -d"#" | xargs)"
ARGS=""

# Check if the source drive has actually been set and is available
if [ -z "$SOURCEDRIVE" ]; then
	echo "[ERROR] Source Drive is not defined."
	echo "        When calling this script manually, make sure to pass the drive path as a variable: ./autorip.sh [DRIVE]"
	exit 1
fi
setcd -i "$SOURCEDRIVE" | grep --quiet 'Disc found'
if [ ! $? ]; then
        echo "[ERROR] $SOURCEDRIVE: Source Drive is not available."
        exit 1
fi

# Construct the arguments for later use
if [[ $OUTPUTDIR == ""\~*"" ]]; then
	if [[ $OUTPUTDIR == ""\~/*"" ]]; then
		OUTPUTDIR=$(echo "$(eval echo ~"${SUDO_USER:-$USER}")/${OUTPUTDIR:2}" | sed 's:/*$::')
	else
		OUTPUTDIR="$(eval echo ~"${SUDO_USER:-$USER}")"
	fi
fi
if [ -d "$OUTPUTDIR" ]; then
	:
else
	echo "[ERROR]: The output directory specified in settings.conf is invalid!"
	exit 1
fi
if [ "$DEBUG" = "true" ]; then
	ARGS="$ARGS --debug"
fi

echo "[INFO] $SOURCEDRIVE: Started ripping process"

#Extract DVD Title from Drive

DISKTITLERAW=$(blkid -o value -s LABEL "$SOURCEDRIVE")
DISKTITLERAW=${DISKTITLERAW// /_}
NOWDATE=$(date +"%F_%H-%M-%S")
DISKTITLE="${DISKTITLERAW}_-_$NOWDATE"

cdrdao read-cd --read-raw --datafile "${OUTPUTDIR}/${DISKTITLE}".bin --device /dev/sr0 --driver generic-mmc-raw "${OUTPUTDIR}/${DISKTITLE}".toc
if [ $? -le 1 ]; then
	echo "[INFO] $SOURCEDRIVE: Ripping finished (exit code $?), ejecting"
else
	echo "[ERROR] $SOURCEDRIVE: RIPPING FAILED (exit code $?), ejecting."
fi

echo "[INFO] Converto toc to cue"
toc2cue "${OUTPUTDIR}/${DISKTITLE}".toc "${OUTPUTDIR}/${DISKTITLE}".cue
if [ $? -le 1 ]; then
	echo "[INFO] $SOURCEDRIVE: Converting toc to cue finished (exit code $?)"
else
	echo "[ERROR] $SOURCEDRIVE: Converting toc to cue FAILED (exit code $?)."
fi

#Removing absolut path from cue file
sed -i "s|$OUTPUTDIR||g" "${OUTPUTDIR}/${DISKTITLE}".cue

echo "[INFO] Converting to chd"
chdman createcd -i "${OUTPUTDIR}/${DISKTITLE}".cue -o "${OUTPUTDIR}/${DISKTITLE}".chd
if [ $? -le 1 ]; then
	echo "[INFO] Converting to chd finished (exit code $?), ejecting"
else
	echo "[ERROR] Converting to chd failed (exit code $?), ejecting."
fi

#Removing bin cue and toc files
rm "${OUTPUTDIR}/${DISKTITLE}".cue "${OUTPUTDIR}/${DISKTITLE}".bin "${OUTPUTDIR}/${DISKTITLE}".toc
eject "$SOURCEDRIVE"