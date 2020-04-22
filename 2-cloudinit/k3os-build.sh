#!/bin/bash
# MIT License. See LICENSE file.

ARG=$1

if [ ! -d $ARG ] ; then
	echo "ARG1 must be a directory, whose name will also be used for the ISO image."
	exit 1
fi


if [ $# -eq 1 ]; then
	FILENAME="cidata-$ARG.iso"
	echo "Building image to $FILENAME ..."
else 
	echo 'Usage: ./k3os-build.sh [dirname]'
	exit 1
fi

# Debian, Ubuntu
#CMD=genisoimage
# SUSE
CMD=mkisofs

# If K3os is configured to use k3os.data_sources=cdrom
# then it is using a version of linuxkit/metadata,
# which expects a file called 'config' at the top level.
(
cd $ARG
rm -f config
ln user-data config

$CMD	 -output ../$FILENAME -volid "cidata" -joliet -rock	\
	./	2> ../build.log
#	config user-data meta-data network-config		\
#	2> ../build.log
)

FILESIZE=$(stat -c %s $FILENAME 2>/dev/null)
COLUMNS=$(tput cols)
if [[ $FILESIZE > 0 ]]; then
	printf '%s (%d bytes) ... done!\n' $FILENAME $FILESIZE
else
	printf 'Something went wrong while trying to make %s\n' $FILENAME
fi

