#!/bin/bash
# MIT License. See LICENSE file.

ARG=$1

################

# check if given ARG is a K3OS iso image
OK=0
if [ -f $ARG ] ; then
	OK=1
	KIND=$( blkid $ARG )
	if [ ! $( echo $KIND | grep -q 'TYPE="iso9660"' ) ] ; then
		OK=2
		if [ ! $( echo $KIND | grep -q 'LABEL="K3OS"' ) ] ; then
			OK=3
		fi
	fi
fi

if [ $OK != 3 ] ; then
	echo "ARG1 must be an ISO image of K3OS."
	exit 1
fi

################

# mount current K3OS image
mkdir -p /mnt/orig /mnt/new
mount -o loop $ARG /mnt/orig

# copy data from orig to new
mkdir -p /mnt/new/boot/grub
cp -rfp /mnt/orig/k3os /mnt/new/

# create new grub.cfg
#cp /mnt/orig/boot/grub/grub.cfg /mnt/new/boot/grub/
cp -p grub/grub-fai3.cfg /mnt/new/boot/grub/grub.cfg

################

if [ $# -eq 1 ]; then
	FNAME=$( basename $ARG)
	FILENAME="new-$FNAME"
	echo "Building image to $FILENAME ..."
else 
	echo 'Usage: ./k3os-remaster.sh [k3os-version].iso'
	exit 1
fi

# Debian, Ubuntu
#CMD=grub-mkrescue
# SUSE
CMD=grub2-mkrescue

# grub-mkrescue -o k3os-new.iso iso/ -- -volid K3OS

# make remastered ISO
$CMD	 -output $FILENAME	/mnt/new/	\
			-- -volid "K3OS" 	\
	2> build.log

################

FILESIZE=$(stat -c %s $FILENAME 2>/dev/null)
COLUMNS=$(tput cols)
if [[ $FILESIZE > 0 ]]; then
	printf '%s (%d bytes) ... done!\n' $FILENAME $FILESIZE
else
	printf 'Something went wrong while trying to make %s\n' $FILENAME
fi

################

# unmount and cleanup
umount /mnt/orig
rm -rf /mnt/new /mnt/orig

